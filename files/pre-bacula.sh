#!/bin/bash -p
# This file is distributed by puppet

export PATH=/usr/sbin:/sbin:/usr/bin:/bin
umask 077

logger $0

df -Th > /etc/partitions.log

pidof postgres postmaster > /dev/null && sudo -u postgres psql -c "SELECT pg_start_backup('bacula `date +%Y%m%d-%H%M`');"

