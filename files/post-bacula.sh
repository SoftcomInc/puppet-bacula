#!/bin/bash -p
# This file is distributed by puppet

export PATH=/usr/sbin:/sbin:/usr/bin:/bin
umask 077

logger $0

pidof postgres postmaster > /dev/null && su postgres -c "psql -c \"SELECT pg_stop_backup();\""

