iCrumz update, backup and restore scripts

Installation on Mac computers:
Note: Complementary server scripts are copied by Ansible
server setup scripts (cargo make host)

0. Open the terminal and execute these commands:
1. Copy the directory iczScripts to /usr/local

	cp ~/Dropbox/Crumz/iczScripts /usr/local

2. Flag directory:

	chmod 750 /usr/local/iczScripts

3. Flag script files:

	chmod 750 /usr/local/iczScripts/*.sh

4. Create aliases in ~/.profile
# Aliases
alias push='/usr/local/iczScripts/iczPush.sh'
alias dump='/usr/local/iczScripts/iczDump.sh'
alias load='/usr/local/iczScripts/iczLoad.sh'
alias nginxctl='/usr/local/iczScripts/iczNginx.sh'
alias gitrev='/usr/local/iczScripts/gitrev.sh'
alias chkcollection='/usr/local/iczScripts/iczChkCollection.sh'

Execute alias name from terminal without options for usage instructions

Instruction to backup each evening

1. Open Terminal
2. cd /Volumes/iCrumz/iCrumz/Backups\ \(development\)/{yyyy}
3. dump production iczdbdump.mm.dd.sql
4. Compress file
5. Upload to iCrumz Cloud: iCrumz/iCrumz/Backups\ \(development\)/{yyyy}