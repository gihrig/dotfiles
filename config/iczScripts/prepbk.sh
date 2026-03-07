#! /bin/bash
# Prepare local system for nightly iCrumz backup

# Mount iCrumzData volume
diskutil mount iCrumz-DATA

# Start MySQL server
#/opt/homebrew/opt/mysql/bin/mysqld_safe --datadir\=/Volumes/iCrumzData/iCrumz/MySQLData

# Change to backup directory
cd /Volumes/iCrumz-DATA/iCrumz/Backup/2026

# List most recent backup file
ls -l | tail -n1
