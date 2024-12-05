#!/bin/bash

# arkDump.sh - install on local client:
# Backup a remote app/db and copy to a local file
# Requires dumphelper.sh on remote server
# remoteusr must have appropriate privileges
#
# Usage: arkDump {mail|staging|production|development|local} {local_filename}
#
# Suport with .profile: alias backup='/usr/local/arkScripts/arkDump.sh'
#
# Server parameters
mailusr="root"
mailname="74.208.37.164"
mailport="22"
maildb=""
maildbuser=""
maildbpw=""

devusr="root"
devname=""
devport="22"
devdb=""
devdbuser=""
devdbpw=""

stgusr="root"
stgname=""
stgport="22"
stgdb=""
stgdbuser=""
stgdbpw=""

produsr="root"
prodname=""
prodport="22"
proddb=""
proddbuser=""
proddbpw=""

localusr=""
localname="localhost"
localport=""
localdb=""
localdbuser=""
localdbpw=""


# Validate parameters
case "$1" in
	mail|production|staging|development|local)
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
	echo "Usage: arkDump {mail|staging|production|development|local} {local_filename} eg: arkdbdump.05.06.sql"
	exit 1
fi

# Setup remote server parameters
case "$srv" in
	mail)
		remoteusr="$mailusr"
		host="$mailname"
		port="$mailport"
		db="$maildb"
		dbuser="$maildbuser"
		dbpw="$maildbpw"
		;;
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
echo "Dumping data on server '$srv' and saving to local file '$fil' ..."

case "$srv" in
	mail|production|staging|development)
		# Check for duplicated collections
		# ssh "$remoteusr"@"$host" -p"$port" "./sqlChkCollection.sh"

		# Execute mysqldump on server and download it's output
		echo "Dumping $host data..."
		ssh "$remoteusr"@"$host" -p"$port" "./dumphelper.sh | gzip -c" | gunzip -c > "$fil"
		echo
		;;
	local)
		export MYSQL_PWD=$dbpw
		mysqldump -u $dbuser --single-transaction --skip-extended-insert --hex-blob $db > $fil
		;;
esac

exit 0
