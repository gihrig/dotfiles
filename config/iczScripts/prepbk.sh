#! /bin/bash
# Prepare local system for nightly iCrumz backup

# Mount iCrumzData volume
diskutil mount iCrumzData

# Start MySQL server
#/opt/homebrew/opt/mysql/bin/mysqld_safe --datadir\=/Volumes/iCrumzData/iCrumz/MySQLData

# Change to backup directory
cd /Volumes/iCrumzData/iCrumz/Backup/2025

# List most recent backup file
ls -l | tail -n1
