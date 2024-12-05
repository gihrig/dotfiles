#!/bin/bash

# iczLoad.sh - install on local client:
# Load a local MySqlDump file to a remote MySql db
# remoteusr must have MySql privileges
#
# Usage: iczLoad {staging|production|local} {local_filename} eg: iczdbdump.05.06.sql
#
# Suport with .profile: alias load='/usr/local/iczScripts/iczLoad.sh'
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
# localdbpw="mit1099"
localdbpw="q~_VMMxYgbXb3*hf?v6d7oz6"


# Validate parameters
case "$1" in
	production|staging|development|local)
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
	echo "Usage: iczLoad {staging|production|development|local} {local_filename} iczdbdump.05.06.sql"
	exit 1
fi

# Setup remote server parameters
case "$srv" in
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

# Execute mysql on server and load local file
case "$srv" in
	production|staging|development)
		echo "Uploading local file '$fil' to '$srv' ..."
		rsync -Paz -e "ssh -p $port" $fil $remoteusr@$host:~/$fil

		echo "Loading local file '$fil' to MySql database $db at '$srv' ..."
		ssh -t "$remoteusr"@"$host" -p"$port" "docker exec -i icrumz_data mysql -u $dbuser -p$dbpw $db < /root/$fil"
		ssh -t "$remoteusr"@"$host" -p"$port" "rm $fil"
		;;
	local)
		export MYSQL_PWD=$dbpw
		echo "Loading local from $fil"
		cat $fil | mysql -u $dbuser $db
		;;
esac

exit 0
