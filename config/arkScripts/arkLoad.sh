#!/bin/bash

# arkLoad.sh - install on local client:
# Load a local MySqlDump file to a remote MySql db
# remoteusr must have MySql privileges
#
# Usage: arkLoad {mail|staging|production|local} {local_filename} eg: arkdbdump.05.06.sql
#
# Suport with .profile: alias restor='/usr/local/arkScripts/arkLoad.sh'
#
# Server parameters
mailusr="root"
mailname="74.208.37.164"
mailport="22"
maildb="Xeams"
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
			fil="$2"
		else
			fil=""
			srv=""
			echo "file $2 not found"
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

# $fil will be empty if the server was unknown, or the file does not exist
if [[ -z "$fil" ]]
then
	echo "Usage: arkLoad {mail|staging|production|development|local} {local_filename} arkdbdump.05.06.sql"
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
		db="$prodb"
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

# Execute operation on server and load local file
case "$srv" in
	mail)
		echo "Uploading local file '$fil' to '$srv/$maildb' ..."
		rsync -Paz -e "ssh -p $port" $fil $remoteusr@$host:~/$fil

		echo "Restoring file '$fil' to app at '$srv' ..."
		ssh -t "$remoteusr"@"$host" -p"$port" "tar -xzpf $fil $maildb"
		ssh -t "$remoteusr"@"$host" -p"$port" "rm $fil"
		;;
	production|staging)
		echo "Uploading local file '$fil' to '$srv' ..."
		rsync -Paz -e "ssh -p $port" $fil $remoteusr@$host:~/$fil

		echo "Loading local file '$fil' to MySql database $db at '$srv' ..."
		ssh -t "$remoteusr"@"$host" -p"$port" "cat $fil | mysql -u $dbuser -p$dbpw $db"
		ssh -t "$remoteusr"@"$host" -p"$port" "rm $fil"
		;;
	development)
		echo "Uploading local file '$fil' to '$srv' ..."
		rsync -Paz -e "ssh -p $port" $fil $remoteusr@$host:~/$fil

		echo "Loading local file '$fil' to MySql database $db at '$srv' ..."
		ssh -t "$remoteusr"@"$host" -p"$port" "docker exec -i icrumz_data mysql -u $dbuser -p$dbpw $db < /root/$fil"
		# ssh -t "$remoteusr"@"$host" -p"$port" "rm $fil"
		;;
	local)
		export MYSQL_PWD=$dbpw
		echo "Loading local from $fil"
		cat $fil | mysql -u $dbuser $db
		;;
esac

exit 0
