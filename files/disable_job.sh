#!/bin/bash
# This file is distributed by puppet

export PATH=/usr/sbin:/sbin:/usr/bin:/bin
umask 077

logger $0 disable job=$1

echo disable job=$1 | bconsole
