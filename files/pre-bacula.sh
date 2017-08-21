#!/bin/bash -p
# This file is distributed by puppet

export PATH=/usr/sbin:/sbin:/usr/bin:/bin
umask 077

cd $(dirname $0)

trap '' INT
trap '' TSTP

export TMPDIR=/var/tmp

set -e
set -o pipefail

# function called on an error to return error to the screen and an exit code
function bailout () {
        error=$1
        shift
        echo -e $error $@
        logger "$0 script aborted at $error"
        exit $error
}

LOCKFILE=$TMPDIR/$(basename $0).lock
[ -f $LOCKFILE ] && bailout 605 "$(basename $0) - lock file exists, exiting"

echo $$ > $LOCKFILE

# TMP=$(mktemp)
trap 'rm $TMP $LOCKFILE' EXIT

logger $0

df -Th > /etc/partitions.log

mkdir /var/backups 2> /dev/null || true

# Mysqldump (if mysql is running)
pidof mysqld > /dev/null && mysqldump --defaults-file=/etc/bacula/scripts/mysql-backupuser.cnf --single-transaction --skip-lock-tables --force --all-databases | bzip2 -c > /var/backups/`hostname`-mysql-full-`date +%A`.sql.bz2 && touch /var/tmp/lastmysqldump.status

# pg_dumpall (if postmaster is running)
pidof postgres postmaster > /dev/null && su postgres -c pg_dumpall | bzip2 -c > /var/backups/`hostname`-pgsql-full-`date +%A`.sql.bz2 && touch /var/tmp/lastpgdump.status

# prepare PG for binary backup
pidof postgres postmaster > /dev/null && su postgres -c "psql -c \"SELECT pg_start_backup('bacula `date +%Y%m%d-%H%M`');\""

