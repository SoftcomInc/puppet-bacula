#!/bin/bash

logger $0 enable job=$1

echo enable job=$1 | bconsole
