#!/bin/bash

# iczChkCollection.sh - from development side:
# Check server db icrumz_collection table for duplicate collection bug
# remoteusr must have MySql privileges
#
# Usage: iczChkCollection {staging|production|development|local}
#
# Suport with .profile: alias chkcollection='/usr/local/iczScripts/iczChkCollection.sh'
#
# Server parameters
devusr="root"
devname=""
devport="22"
devdb="icrumz_main"
devdbuser="root"
devdbpw="thi7re1xu7jo"

stgusr="root"
stgname="74.208.214.213"
stgport="22"
stgdb="icrumz_main"
stgdbuser="root"
stgdbpw="thi7re1xu7jo"

produsr="root"
prodname="198.71.48.77"
prodport="22"
proddb="icrumz_main"
proddbuser="root"
proddbpw="thi7re1xu7jo"

localusr="root"
localname="localhost"
localport=""
localdb="icrumz_main"
localdbuser="root"
localdbpw="mit1099"


# Validate parameters
case "$1" in
	production|staging|development|local)
		srv="$1"
		;;
	*)
	# an unknown server was entered
	echo
	echo "'$1' is not a valid server"
	echo
	echo "Usage: chkcollection {staging|production|development|local}"
	echo
	exit 1
		;;
 esac

# Setup remote server parameters
case "$srv" in
	production)
		remoteusr="$produsr"
		host="$prodname"
		port="$prodport"
		db="$proddb"
		dbuser="$proddbuser"
		dbpw="$proddbpw"
		;;
	staging)
		remoteusr="$stgusr"
		host="$stgname"
		port="$stgport"
		db="$stgdb"
		dbuser="$stgdbuser"
		dbpw="$stgdbpw"
		;;
	development)
		remoteusr="$devusr"
		host="$devname"
		port="$devport"
		db="$devdb"
		dbuser="$devdbuser"
		dbpw="$devdbpw"
		;;
	local)
		remoteusr="$localusr"
		host="$localname"
		port="$localport"
		db="$localdb"
		dbuser="$localdbuser"
		dbpw="$localdbpw"
		;;
	*)
		exit 1
		;;
esac

# Ready to get to work

# Execute sqlChkCollection.sh on $host
case "$srv" in
	production|staging|development)
		ssh "$remoteusr"@"$host" -p"$port" "~/sqlChkCollection.sh"
		;;
	local)
		export MYSQL_PWD=$dbpw
		/usr/local/iczScripts/sqlChkCollection.sh
		;;
esac

exit 0
