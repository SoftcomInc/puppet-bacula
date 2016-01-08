#!/bin/bash
# This file is distributed by puppet

export PATH=/usr/sbin:/sbin:/usr/bin:/bin
umask 077

logger $0 enable job=$1

echo enable job=$1 | bconsole
