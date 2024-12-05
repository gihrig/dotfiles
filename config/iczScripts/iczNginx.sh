#!/bin/bash

# iczNginx.sh - install on local client:
# Shutdown apple installed apache and start nginx on port 80
#
# Usage: iczNginx {start|stop}
#
# Suport with .profile: alias nginxctl='/usr/local/iczScripts/iczNginx.sh'
#

# Swap web servers
case "$1" in
	start)
		echo $"Shutting down apache..."
		sudo apachectl stop
		echo $"Starting nginx..."
		sudo /usr/local/bin/nginx
		;;
	restart)
		echo $"Restarting nginx..."
		sudo /usr/local/bin/nginx -s reload
		;;
	stop)
		echo $"Shutting down nginx..."
		sudo /usr/local/bin/nginx -s stop
		echo $"Starting apache..."
		sudo apachectl start
		;;
	*)
		echo $"invalid parameter $1"
		;;
 esac

if [ -z "$1" ]
then
	echo $"Usage: nginxctl {start|restart|stop}"
	echo $"Replaces apache:80 with nginx:80"
	exit 1
fi
