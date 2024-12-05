#!/bin/bash

# iczDump.sh - install on local client:
# MySQLDump a remote db and copy to a local file
# Requires dumphelper.sh on remote server
# remoteusr must have MySql privileges
#
# Usage: iczDump {staging|production|local} {local_filename}
#
# Suport with .profile: alias dump='/usr/local/iczScripts/iczDump.sh'
#
# Server parameters
devusr="root"
devname=""
devport="22"
devdb="icrumz_main"
devdbuser="root"
devdbpw="thi7re1xu7jo"

stgusr="root"
stgname="server2.icrumz.com"
stgport="22"
stgdb="icrumz_main"
stgdbuser="root"
stgdbpw="thi7re1xu7jo"

produsr="root"
prodname="server1.icrumz.com"
prodport="22"
proddb="icrumz_main"
proddbuser="root"
proddbpw="thi7re1xu7jo"

localusr="root"
localname="localhost"
localport=""
localdb="icrumz_main"
localdbuser="root"
localdbpw="q~_VMMxYgbXb3*hf?v6d7oz6"


# Validate parameters
case "$1" in
	production|staging|development|local)
		srv="$1"
		if [ -e "$2" ]
		then
			fil=""
			srv=""
			echo "file $2 already exists"
		else
			fil="$2"
		fi
		;;
	*)
	# an unknown server was entered
		if [ $1 ]
		then
			echo "'$1' is not a valid server"
			fil=""
			srv=""
		fi
		;;
 esac

# $fil will be empty if the server was unknown, the file exists or was not entered
if [[ -z "$fil" ]]
then
	echo "Usage: iczDump {staging|production|development|local} {local_filename} eg: iczdbdump.05.06.sql"
	exit 1
fi

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
echo
echo "Dumping MySql on server '$srv' and saving to local file '$fil' ..."

case "$srv" in
	production|staging|development)
		# Check for duplicated collections
		ssh "$remoteusr"@"$host" -p "$port" ./sqlChkCollection.sh

		# Execute mysqldump on server and download it's output
		echo "Dumping MySql..."
		ssh "$remoteusr"@"$host" -p "$port" ./dumphelper.sh | gzip -c | gunzip -c > "$fil"
		echo
		;;
	local)
		export MYSQL_PWD=$dbpw
		mysqldump -u $dbuser --single-transaction --skip-extended-insert --hex-blob $db > $fil
		;;
esac

exit 0
