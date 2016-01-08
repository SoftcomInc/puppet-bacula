#!/bin/bash

logger $0 disable job=$1

echo disable job=$1 | bconsole
