#!/bin/bash
#
# MySQL Backup Script
# VER. 2.5.1 - http://sourceforge.net/projects/automysqlbackup/
# Copyright (c) 2002-2003 wipe_out@lycos.co.uk
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================
#=====================================================================
# Set the following variables to your system needs
# (Detailed instructions below variables)
#=====================================================================
#set -x

### if [ -e "/srv/www/kuhpatenschaft/forbidden/auto.lock" ]; then
### 	echo "Only one backup at once"
### 	exit 1
### fi
### touch /srv/www/kuhpatenschaft/forbidden/auto.lock 

CONFIGFILE="/srv/www/kuhpatenschaft/forbidden/auto.conf"

if [ -r ${CONFIGFILE} ]; then
	# Read the configfile if it's existing and readable
	source ${CONFIGFILE}
else
	# do inline-config otherwise
	# To create a configfile just copy the code between "### START CFG ###" and "### END CFG ###"
	# to /etc/automysqlbackup/automysqlbackup.conf. After that you're able to upgrade this script
	# (copy a new version to its location) without the need for editing it.
	### START CFG ###
	# Username to access the MySQL server e.g. dbuser
	USERNAME=debian
	
	# Password to access the MySQL server e.g. password
	PASSWORD=
	
	# Host name (or IP address) of MySQL server e.g localhost
	DBHOST=localhost
	
	# Port of MySQL sever connection
	DBPORT=3306
	
	# List of DBNAMES for Daily/Weekly Backup e.g. "DB1 DB2 DB3"
	DBNAMES="all"
	
	# Backup directory location e.g /backups
	BACKUPDIR="/srv/backup/db"
	
	# Mail setup
	# What would you like to be mailed to you?
	# - log   : send only log file
	# - files : send log file and sql files as attachments (see docs)
	# - stdout : will simply output the log to the screen if run manually.
	# - quiet : Only send logs if an error occurs to the MAILADDR.
	MAILCONTENT="log"
	
	# Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])
	MAXATTSIZE="4000"
	
	# Email Address to send mail to? (user@domain.com)
	MAILADDR="maintenance@example.com"
	
	
	# ============================================================
	# === ADVANCED OPTIONS ( Read the doc's below for details )===
	#=============================================================
	
	# List of DBBNAMES for Monthly Backups.
	MDBNAMES="${DBNAMES}"
	
	# List of DBNAMES to EXLUCDE if DBNAMES are set to all (must be in " quotes)
	DBEXCLUDE=""
	
	# Include CREATE DATABASE in backup?
	CREATE_DATABASE=no
	
	# Separate backup directory and file for each DB? (yes or no)
	SEPDIR=yes
	
	# Which day do you want weekly backups? (1 to 7 where 1 is Monday)
	DOWEEKLY=6
	
	# Choose Compression type. (gzip or bzip2)
	COMP=gzip
	
	# Compress communications between backup server and MySQL server?
	COMMCOMP=no
	
	# Additionally keep a copy of the most recent backup in a seperate directory.
	LATEST=no
	
	#  The maximum size of the buffer for client/server communication. e.g. 16MB (maximum is 1GB)
	MAX_ALLOWED_PACKET=
	
	#  For connections to localhost. Sometimes the Unix socket file must be specified.
	SOCKET=
	
	# Command to run before backups (uncomment to use)
	#PREBACKUP="/etc/mysql-backup-pre"
	
	# Command run after backups (uncomment to use)
	#POSTBACKUP="/etc/mysql-backup-post"
	### END CFG ###
fi

#=====================================================================
# Options documantation
#=====================================================================
# Set USERNAME and PASSWORD of a user that has the appropriate permissions
# to backup ALL databases. (See mysql documentation for details)
# NEW in 2.5.1:
# - If USERNAME is set to "debian" and PASSWORD is unset or "" obtain
#   them from the file /etc/mysql/debian.cnf
# - First command line option "-c" for configfile
# - Interpretable Exit-States:
#    1: given configfile is not readable or does not exist
#    2: unknown option
#
# Set the DBHOST option to the server you wish to backup, leave the
# default to backup "this server".(to backup multiple servers make
# copies of this file and set the options for that server)
#
# Put in the list of DBNAMES(Databases)to be backed up. If you would like
# to backup ALL DBs on the server set DBNAMES="all".(if set to "all" then
# any new DBs will automatically be backed up without needing to modify
# this backup script when a new DB is created).
#
# If the DB you want to backup has a space in the name replace the space
# with a % e.g. "data base" will become "data%base"
# NOTE: Spaces in DB names may not work correctly when SEPDIR=no.
#
# You can change the backup storage location from /backups to anything
# you like by using the BACKUPDIR setting..
#
# The MAILCONTENT and MAILADDR options and pretty self explanitory, use
# these to have the backup log mailed to you at any email address or multiple
# email addresses in a space seperated list.
# (If you set mail content to "log" you will require access to the "mail" program
# on your server. If you set this to "files" you will have to have mutt installed
# on your server. If you set it to "stdout" it will log to the screen if run from 
# the console or to the cron job owner if run through cron. If you set it to "quiet"
# logs will only be mailed if there are errors reported. )
#
# MAXATTSIZE sets the largest allowed email attachments total (all backup files) you
# want the script to send. This is the size before it is encoded to be sent as an email
# so if your mail server will allow a maximum mail size of 5MB I would suggest setting
# MAXATTSIZE to be 25% smaller than that so a setting of 4000 would probably be fine.
#
# Finally copy automysqlbackup.sh to anywhere on your server and make sure
# to set executable permission. You can also copy the script to
# /etc/cron.daily to have it execute automatically every night or simply
# place a symlink in /etc/cron.daily to the file if you wish to keep it 
# somwhere else.
# NOTE:On Debian copy the file with no extention for it to be run
# by cron e.g just name the file "automysqlbackup"
#
# Thats it..
#
#
# === Advanced options doc's ===
#
# The list of MDBNAMES is the DB's to be backed up only monthly. You should
# always include "mysql" in this list to backup your user/password
# information along with any other DBs that you only feel need to
# be backed up monthly. (if using a hosted server then you should
# probably remove "mysql" as your provider will be backing this up)
# NOTE: If DBNAMES="all" then MDBNAMES has no effect as all DBs will be backed
# up anyway.
#
# If you set DBNAMES="all" you can configure the option DBEXCLUDE. Other
# wise this option will not be used.
# This option can be used if you want to backup all dbs, but you want 
# exclude some of them. (eg. a db is to big).
#
# Set CREATE_DATABASE to "yes" (the default) if you want your SQL-Dump to create
# a database with the same name as the original database when restoring.
# Saying "no" here will allow your to specify the database name you want to
# restore your dump into, making a copy of the database by using the dump
# created with automysqlbackup.
# NOTE: Not used if SEPDIR=no
#
# The SEPDIR option allows you to choose to have all DBs backed up to
# a single file (fast restore of entire server in case of crash) or to
# seperate directories for each DB (each DB can be restored seperately
# in case of single DB corruption or loss).
#
# To set the day of the week that you would like the weekly backup to happen
# set the DOWEEKLY setting, this can be a value from 1 to 7 where 1 is Monday,
# The default is 6 which means that weekly backups are done on a Saturday.
#
# COMP is used to choose the copmression used, options are gzip or bzip2.
# bzip2 will produce slightly smaller files but is more processor intensive so
# may take longer to complete.
#
# COMMCOMP is used to enable or diable mysql client to server compression, so
# it is useful to save bandwidth when backing up a remote MySQL server over
# the network. 
#
# LATEST is to store an additional copy of the latest backup to a standard
# location so it can be downloaded bt thrid party scripts.
#
# If the DB's being backed up make use of large BLOB fields then you may need
# to increase the MAX_ALLOWED_PACKET setting, for example 16MB..
#
# When connecting to localhost as the DB server (DBHOST=localhost) sometimes
# the system can have issues locating the socket file.. This can now be set
# using the SOCKET parameter.. An example may be SOCKET=/private/tmp/mysql.sock
#
# Use PREBACKUP and POSTBACKUP to specify Per and Post backup commands
# or scripts to perform tasks either before or after the backup process.
#
#
#=====================================================================
# Backup Rotation..
#=====================================================================
#
# Daily Backups are rotated weekly..
# Weekly Backups are run by default on Saturday Morning when
# cron.daily scripts are run...Can be changed with DOWEEKLY setting..
# Weekly Backups are rotated on a 5 week cycle..
# Monthly Backups are run on the 1st of the month..
# Monthly Backups are rotated on a 5 month cycle...
# It may be a good idea to copy Monthly backups offline or to another
# server..
#
#=====================================================================
# Please Note!!
#=====================================================================
#
# I take no resposibility for any data loss or corruption when using
# this script..
# This script will not help in the event of a hard drive crash. If a 
# copy of the backup has not be stored offline or on another PC..
# You should copy your backups offline regularly for best protection.
#
# Happy backing up...
#
#=====================================================================
# Restoring
#=====================================================================
# Firstly you will need to uncompress the backup file.
# eg.
# gunzip file.gz (or bunzip2 file.bz2)
#
# Next you will need to use the mysql client to restore the DB from the
# sql file.
# eg.
# mysql --user=username --pass=password --host=dbserver database < /path/file.sql
# or
# mysql --user=username --pass=password --host=dbserver -e "source /path/file.sql" database
#
# NOTE: Make sure you use "<" and not ">" in the above command because
# you are piping the file.sql to mysql and not the other way around.
#
# Lets hope you never have to use this.. :)
#
#=====================================================================
# Change Log
#=====================================================================
#
# VER 2.5.1-01 - (2010-07-06)
#     - Fixed pathname bug item #3025849 (by Johannes Kolter)
# VER 2.5.1 - (2010-07-04)
#     - Added support for default and optional config file (by Johannes Kolter)
#     - Rotating after backup was successful whith find(1) (by Johannes Kolter)
#     - Implementation of Variables containing full path to binaries to
#       avoid possibly confusion with aliases or builtins. (by Johannes Kolter)
#     - Fixed bug where weekly backups were not being rotated.
#       Added rotation of 5 monthly backups
#       Now all old backups are deleted, not only the most recent one
#       (inspired by oleg@bintime.com)
#     - Use Debian special-file to access database (by Johannes Kolter)
#     - Fixed bug ID: 1438565
#       Moved IO redirection to a place before decicions are made and actions are taken.
#       (inspired by Derk Bernhardt)
#     - Fixed bug ID: #3000316 (reported by Sascha Feldhorst)
#     - Fixed bug ID: #1529458 (reported by Natalie ( njwood ))
#     - Fixed bug ID: #1548919 (reported by Piotr Kuczynski)
# VER 2.5 - (2006-01-15)
#		Added support for setting MAXIMUM_PACKET_SIZE and SOCKET parameters (suggested by Yvo van Doorn)
# VER 2.4 - (2006-01-23)
#    Fixed bug where weekly backups were not being rotated. (Fix by wolf02)
#    Added hour an min to backup filename for the case where backups are taken multiple
#    times in a day. NOTE This is not complete support for mutiple executions of the script
#    in a single day.
#    Added MAILCONTENT="quiet" option, see docs for details. (requested by snowsam)
#    Updated path statment for compatibility with OSX.
#    Added "LATEST" to additionally store the last backup to a standard location. (request by Grant29)
# VER 2.3 - (2005-11-07)
#    Better error handling and notification of errors (a long time coming)
#    Compression on Backup server to MySQL server communications. 
# VER 2.2 - (2004-12-05)
#    Changed from using depricated "-N" to "--skip-column-names".
#    Added ability to have compressed backup's emailed out. (code from Thomas Heiserowski)
#    Added maximum attachment size setting.
# VER 2.1 - (2004-11-04)
#    Fixed a bug in daily rotation when not using gzip compression. (Fix by Rob Rosenfeld)
# VER 2.0 - (2004-07-28)
#    Switched to using IO redirection instead of pipeing the output to the logfile.
#    Added choice of compression of backups being gzip of bzip2.
#    Switched to using functions to facilitate more functionality.
#    Added option of either gzip or bzip2 compression. 
# VER 1.10 - (2004-07-17)
#    Another fix for spaces in the paths (fix by Thomas von Eyben)
#    Fixed bug when using PREBACKUP and POSTBACKUP commands containing many arguments.
# VER 1.9 - (2004-05-25)
#    Small bug fix to handle spaces in LOGFILE path which contains spaces (reported by Thomas von Eyben)
#    Updated docs to mention that Log email can be sent to multiple email addresses.
# VER 1.8 - (2004-05-01)
#    Added option to make backups restorable to alternate database names
#    meaning that a copy of the database can be created (Based on patch by Rene Hoffmann)
#    Seperated options into standard and advanced.
#    Removed " from single file dump DBMANES because it caused an error but
#    this means that if DB's have spaces in the name they will not dump when SEPDIR=no.
#    Added -p option to mkdir commands to create multiple subdirs without error.
#    Added disk usage and location to the bottom of the backup report.
# VER 1.7 - (2004-04-22)
#    Fixed an issue where weelky backups would only work correctly if server
#    locale was set to English (issue reported by Tom Ingberg)
#    used "eval" for "rm" commands to try and resolve rotation issues.
#    Changed name of status log so multiple scripts can be run at the same time.
# VER 1.6 - (2004-03-14)
#   Added PREBACKUP and POSTBACKUP command functions. (patch by markpustjens)
#   Added support for backing up DB's with Spaces in the name.
#   (patch by markpustjens)
# VER 1.5 - (2004-02-24)
#   Added the ability to exclude DB's when the "all" option is used.
#   (Patch by kampftitan)
# VER 1.4 - (2004-02-02)
#   Project moved to Sourceforge.net
# VER 1.3 - (2003-09-25)
#   Added support for backing up "all" databases on the server without
#    having to list each one seperately in the configuration.
#   Added DB restore instructions.
# VER 1.2 - (2003-03-16)
#   Added server name to the backup log so logs from multiple servers
#   can be easily identified.
# VER 1.1 - (2003-03-13)
#   Small Bug fix in monthly report. (Thanks Stoyanski)
#   Added option to email log to any email address. (Inspired by Stoyanski)
#   Changed Standard file name to .sh extention.
#   Option are set using yes and no rather than 1 or 0.
# VER 1.0 - (2003-01-30)
#   Added the ability to have all databases backup to a single dump
#   file or seperate directory and file for each database.
#   Output is better for log keeping.
# VER 0.6 - (2003-01-22)
#   Bug fix for daily directory (Added in VER 0.5) rotation.
# VER 0.5 - (2003-01-20)
#   Added "daily" directory for daily backups for neatness (suggestion by Jason)
#   Added DBHOST option to allow backing up a remote server (Suggestion by Jason)
#   Added "--quote-names" option to mysqldump command.
#   Bug fix for handling the last and first of the year week rotation.
# VER 0.4 - (2002-11-06)
#   Added the abaility for the script to create its own directory structure.
# VER 0.3 - (2002-10-01)
#   Changed Naming of Weekly backups so they will show in order.
# VER 0.2 - (2002-09-27)
#   Corrected weekly rotation logic to handle weeks 0 - 10 
# VER 0.1 - (2002-09-21)
#   Initial Release
#
#=====================================================================
#=====================================================================
#=====================================================================
#
# Should not need to be modified from here down!!
#
#=====================================================================
#=====================================================================
#=====================================================================
#
# Full pathname to binaries to avoid problems with aliases and builtins etc.
#
WHICH="`which which`"
#AWK="`${WHICH} gawk`"
#LOGGER="`${WHICH} logger`"
ECHO="echo"
CAT="cat"
BASENAME="basename"
DATEC="date"
DU="du"
EXPR="expr"
FIND="find"
RM="rm"
MYSQL="mysql"
MYSQLDUMP="mysqldump"
GZIP="gzip"
BZIP2="bzip2"
CP="cp"
#HOSTNAMEC="hostname"
SED="sed"
GREP="grep"
TAR="tar"





while [ $# -gt 0 ]; do
	case $1 in
		-c)
			if [ -r "$2" ]; then
				source "$2"
				shift 2
			else
				${ECHO} "Unreadable config file \"$2\""
				exit 1
			fi
			;;
		*)
			${ECHO} "Unknown Option \"$1\""
			exit 2
			;;
	esac
done


export LC_ALL=C
PROGNAME=`${BASENAME} $0`

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/mysql/bin 
DATE=`${DATEC} +%Y-%m-%d_%Hh%Mm`				# Datestamp e.g 2002-09-21
DOW=`${DATEC} +%A`							# Day of the week e.g. Monday
DNOW=`${DATEC} +%u`						# Day number of the week 1 to 7 where 1 represents Monday
DOM=`${DATEC} +%d`							# Date of the Month e.g. 27
M=`${DATEC} +%B`							# Month e.g January
W=`${DATEC} +%V`							# Week Number e.g 37
VER=2.5.1									# Version Number
LOGFILE=${BACKUPDIR}/${DBHOST}-`${DATEC} +%N`.log		# Logfile Name
LOGERR=${BACKUPDIR}/ERRORS_${DBHOST}-`${DATEC} +%N`.log		# Logfile Name
BACKUPFILES=""
OPT="--quote-names  --opt --skip-lock-tables --skip-add-locks"			# OPT string for use with mysqldump ( see man mysqldump )

# IO redirection for logging.
touch ${LOGFILE}
exec 6>&1           # Link file descriptor #6 with stdout.
                    # Saves stdout.
#exec > ${LOGFILE}     # stdout replaced with file ${LOGFILE}.
touch ${LOGERR}
exec 7>&2           # Link file descriptor #7 with stderr.
                    # Saves stderr.
exec 2> ${LOGERR}     # stderr replaced with file ${LOGERR}.


# Add --compress mysqldump option to ${OPT}
if [ "${COMMCOMP}" = "yes" ];
	then
		OPT="${OPT} --compress"
	fi

# Add --max_allowed_packet=... mysqldump option to ${OPT}
if [ "${MAX_ALLOWED_PACKET}" ];
	then
		OPT="${OPT} --max_allowed_packet=${MAX_ALLOWED_PACKET}"
	fi

# Create required directories
if [ ! -e "${BACKUPDIR}" ]		# Check Backup Directory exists.
	then
	mkdir -p "${BACKUPDIR}"
fi

if [ ! -e "${BACKUPDIR}/daily" ]		# Check Daily Directory exists.
	then
	mkdir -p "${BACKUPDIR}/daily"
fi

if [ ! -e "${BACKUPDIR}/weekly" ]		# Check Weekly Directory exists.
	then
	mkdir -p "${BACKUPDIR}/weekly"
fi

if [ ! -e "${BACKUPDIR}/monthly" ]	# Check Monthly Directory exists.
	then
	mkdir -p "${BACKUPDIR}/monthly"
fi

if [ "${LATEST}" = "yes" ]
then
  eval ${RM} "${BACKUPDIR}/latest/*"
	if [ ! -e "${BACKUPDIR}/latest" ]	# Check Latest Directory exists.
	then
		mkdir -p "${BACKUPDIR}/latest"
	fi
fi


# Functions

# Database dump function
dbdump () {
#echo "mkdir -p ${2}"
mkdir -p ${2}
A='.'
echo ${MYSQL} -s --skip-column-names --user=$USERNAME --password="'$PASSWORD'" --host=$DBHOST -D ${1} -e \'show tables\'
# for I in $(${MYSQL} -s --skip-column-names --user=${USERNAME} --password='${PASSWORD}' --host=${DBHOST} -D ${1} -e \'show tables\')
for I in $(${MYSQL} -s --skip-column-names --user=${USERNAME} --password="${PASSWORD}" --host=${DBHOST} -D ${1} -e 'show tables')
do 
  LOOPBREAK=0
  for J in ${STRUCTUREONLYTABLES[@]}
  do
   if [ "$I" == "$J" ]
   then
     LOOPBREAK=1
   fi
  done
  
  if [ "${LOOPBREAK}" -ne 0 ]
  then
		echo ${MYSQLDUMP} --no-data --user=${USERNAME} --password="${PASSWORD}" --host=${DBHOST} ${OPT} ${1} ${I} \> ${2}/${I}.sql
    ${MYSQLDUMP} --no-data --user=${USERNAME} --password="${PASSWORD}" --host=${DBHOST} ${OPT} ${1} ${I} > ${2}/${I}.sql
  else
		echo ${MYSQLDUMP} --user=${USERNAME} --password="${PASSWORD}" --host=${DBHOST} ${OPT} ${1} ${I} \> ${2}/${I}.sql
    ${MYSQLDUMP} --user=${USERNAME} --password="${PASSWORD}" --host=${DBHOST} ${OPT} ${1} ${I} > ${2}/${I}.sql
  fi
done
return $?
}

# Compression function plus latest copy
SUFFIX=""
compression () {
if [ "${COMP}" = "gzip" ]; then
	${TAR} -Pczf "${1}.tgz" "${1}"
  rm -r "${1}"
	${ECHO}
	${ECHO} Backup Information for "${1}"
	${TAR} -tzf "${1}.tgz"
	SUFFIX=".tgz"
else
	${ECHO} "No compression option set, check advanced settings"
fi
if [ "${LATEST}" = "yes" ]; then
	${CP} ${1}${SUFFIX} "${BACKUPDIR}/latest/"
fi	
return 0
}


# Run command before we begin
if [ "${PREBACKUP}" ]
	then
	${ECHO} ======================================================================
	${ECHO} "Prebackup command output."
	${ECHO}
	eval ${PREBACKUP}
	${ECHO}
	${ECHO} ======================================================================
	${ECHO}
fi


if [ "${SEPDIR}" = "yes" ]; then # Check if CREATE DATABSE should be included in Dump
	if [ "${CREATE_DATABASE}" = "no" ]; then
		OPT="${OPT} --no-create-db"
	else
		OPT="${OPT} --databases"
	fi
else
	OPT="${OPT} --databases"
fi

# Hostname for LOG information
if [ "${DBHOST}" = "localhost" ]; then
	HOST=`${HOSTNAMEC}`
	if [ "${SOCKET}" ]; then
		OPT="${OPT} --socket=${SOCKET}"
	fi
	if [ "${DBPORT}" ]; then
		OPT="${OPT} --port=${DBPORT}"
	fi
else
	HOST=${DBHOST}
fi

# If backing up all DBs on the server
if [ "${DBNAMES}" = "all" ]; then
        echo "`${MYSQL} --user=${USERNAME} --password="'${PASSWORD}'" --host=${DBHOST} --batch --skip-column-names -e 'show databases'| ${SED} 's/ /%/g'`"
        DBNAMES="`${MYSQL} --user=${USERNAME} --password="${PASSWORD}" --host=${DBHOST} --batch --skip-column-names -e 'show databases'| ${SED} 's/ /%/g'`"

	# If DBs are excluded
	for exclude in ${DBEXCLUDE}
	do
		DBNAMES=`${ECHO} ${DBNAMES} | ${SED} "s/\b${exclude}\b//g"`
	done

        MDBNAMES=${DBNAMES}
fi
	
${ECHO} ======================================================================
${ECHO} AutoMySQLBackup VER ${VER}
${ECHO} http://sourceforge.net/projects/automysqlbackup/
${ECHO} 
${ECHO} Backup of Database Server - ${HOST}
${ECHO} ======================================================================

# Test is seperate DB backups are required
if [ "${SEPDIR}" = "yes" ]; then
${ECHO} Backup Start Time `${DATEC}`
${ECHO} ======================================================================
	# Monthly Full Backup of all Databases
	if [ ${DOM} = "01" ]; then
		for MDB in ${MDBNAMES}
		do
 
			 # Prepare ${DB} for using
		        MDB="`${ECHO} ${MDB} | ${SED} 's/%/ /g'`"

			if [ ! -e "${BACKUPDIR}/monthly/${MDB}" ]		# Check Monthly DB Directory exists.
			then
				mkdir -p "${BACKUPDIR}/monthly/${MDB}"
			fi
			${ECHO} Monthly Backup of ${MDB}...
				dbdump "${MDB}" "${BACKUPDIR}/monthly/${MDB}/${MDB}_${DATE}.${M}.${MDB}"
				[ $? -eq 0 ] && {
					${ECHO} "Rotating 5 month backups for ${MDB}"
					${FIND} "${BACKUPDIR}/monthly/${MDB}" -mtime +150 -type f -exec ${RM} -v {} \; 
				}
				compression "${BACKUPDIR}/monthly/${MDB}/${MDB}_${DATE}.${M}.${MDB}"
				BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/monthly/${MDB}/${MDB}_${DATE}.${M}.${MDB}${SUFFIX}"
			${ECHO} ----------------------------------------------------------------------
		done
	fi

	for DB in ${DBNAMES}
	do
	# Prepare ${DB} for using
	DB="`${ECHO} ${DB} | ${SED} 's/%/ /g'`"
	
	# Create Seperate directory for each DB
	if [ ! -e "${BACKUPDIR}/daily/${DB}" ]		# Check Daily DB Directory exists.
		then
		mkdir -p "${BACKUPDIR}/daily/${DB}"
	fi
	
	if [ ! -e "${BACKUPDIR}/weekly/${DB}" ]		# Check Weekly DB Directory exists.
		then
		mkdir -p "${BACKUPDIR}/weekly/${DB}"
	fi
	
	# Weekly Backup
	if [ ${DNOW} = ${DOWEEKLY} ]; then
		${ECHO} Weekly Backup of Database \( ${DB} \)
		${ECHO}
			dbdump "${DB}" "${BACKUPDIR}/weekly/${DB}/${DB}_week.${W}.${DATE}"
			[ $? -eq 0 ] && {
				${ECHO} Rotating 5 weeks Backups...
				${FIND} "${BACKUPDIR}/weekly/${DB}" -mtime +35 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/weekly/${DB}/${DB}_week.${W}.${DATE}"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/weekly/${DB}/${DB}_week.${W}.${DATE}${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	
	# Daily Backup
	else
		${ECHO} Daily Backup of Database \( ${DB} \)
		${ECHO}
			dbdump "${DB}" "${BACKUPDIR}/daily/${DB}/${DB}_${DATE}.${DOW}"
			[ $? -eq 0 ] && {
				${ECHO} Rotating last weeks Backup...
				${FIND} "${BACKUPDIR}/daily/${DB}" -mtime +6 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/daily/${DB}/${DB}_${DATE}.${DOW}"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/daily/${DB}/${DB}_${DATE}.${DOW}${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	fi
	done
${ECHO} Backup End `${DATEC}`
${ECHO} ======================================================================


else # One backup file for all DBs
${ECHO} Backup Start `${DATEC}`
${ECHO} ======================================================================
	# Monthly Full Backup of all Databases
	if [ ${DOM} = "01" ]; then
		${ECHO} Monthly full Backup of \( ${MDBNAMES} \)...
			dbdump "${MDBNAMES}" "${BACKUPDIR}/monthly/${DATE}.${M}.all-databases"
			[ $? -eq 0 ] && {
				${ECHO} "Rotating 5 month backups."
				${FIND} "${BACKUPDIR}/monthly" -mtime +150 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/monthly/${DATE}.${M}.all-databases"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/monthly/${DATE}.${M}.all-databases${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	fi

	# Weekly Backup
	if [ ${DNOW} = ${DOWEEKLY} ]; then
		${ECHO} Weekly Backup of Databases \( ${DBNAMES} \)
		${ECHO}
		${ECHO}
			dbdump "${DBNAMES}" "${BACKUPDIR}/weekly/week.${W}.${DATE}"
			[ $? -eq 0 ] && {
				${ECHO} Rotating 5 weeks Backups...
				${FIND} "${BACKUPDIR}/weekly/" -mtime +35 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/weekly/week.${W}.${DATE}"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/weekly/week.${W}.${DATE}${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
		
	# Daily Backup
	else
		${ECHO} Daily Backup of Databases \( ${DBNAMES} \)
		${ECHO}
		${ECHO}
			dbdump "${DBNAMES}" "${BACKUPDIR}/daily/${DATE}.${DOW}"
			[ $? -eq 0 ] && {
				${ECHO} Rotating last weeks Backup...
				${FIND} "${BACKUPDIR}/daily" -mtime +6 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/daily/${DATE}.${DOW}"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/daily/${DATE}.${DOW}${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	fi
${ECHO} Backup End Time `${DATEC}`
${ECHO} ======================================================================
fi
${ECHO} Total disk space used for backup storage..
${ECHO} Size - Location
${ECHO} `${DU} -hs "${BACKUPDIR}"`
${ECHO}
${ECHO} ======================================================================
${ECHO} If you find AutoMySQLBackup valuable please make a donation at
${ECHO} http://sourceforge.net/project/project_donations.php?group_id=101066
${ECHO} ======================================================================

# Run command when we're done
if [ "${POSTBACKUP}" ]
	then
	${ECHO} ======================================================================
	${ECHO} "Postbackup command output."
	${ECHO}
	eval ${POSTBACKUP}
	${ECHO}
	${ECHO} ======================================================================
fi

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 2>&7 7>&-      # Restore stdout and close file descriptor #7.

if [ "${MAILCONTENT}" = "files" ]
then
	if [ -s "${LOGERR}" ]
	then
		# Include error log if is larger than zero.
		BACKUPFILES="${BACKUPFILES} ${LOGERR}"
		ERRORNOTE="WARNING: Error Reported - "
	fi
	#Get backup size
	ATTSIZE=`${DU} -c ${BACKUPFILES} | ${GREP} "[[:digit:][:space:]]total$" |${SED} s/\s*total//`
	if [ ${MAXATTSIZE} -ge ${ATTSIZE} ]
	then
		BACKUPFILES=`${ECHO} "${BACKUPFILES}" | ${SED} -e "s# # -a #g"`	#enable multiple attachments
		mutt -s "${ERRORNOTE} MySQL Backup Log and SQL Files for ${HOST} - ${DATE}" ${BACKUPFILES} ${MAILADDR} < ${LOGFILE}		#send via mutt
	else
		${CAT} "${LOGFILE}" | mail -s "WARNING! - MySQL Backup exceeds set maximum attachment size on ${HOST} - ${DATE}" ${MAILADDR}
	fi
elif [ "${MAILCONTENT}" = "log" ]
then
	${CAT} "${LOGFILE}" | mail -s "MySQL Backup Log for ${HOST} - ${DATE}" ${MAILADDR}
	if [ -s "${LOGERR}" ]
		then
			${CAT} "${LOGERR}" | mail -s "ERRORS REPORTED: MySQL Backup error Log for ${HOST} - ${DATE}" ${MAILADDR}
	fi	
elif [ "${MAILCONTENT}" = "quiet" ]
then
	if [ -s "${LOGERR}" ]
		then
			${CAT} "${LOGERR}" | mail -s "ERRORS REPORTED: MySQL Backup error Log for ${HOST} - ${DATE}" ${MAILADDR}
			${CAT} "${LOGFILE}" | mail -s "MySQL Backup Log for ${HOST} - ${DATE}" ${MAILADDR}
	fi
else
	if [ -s "${LOGERR}" ]
		then
			${CAT} "${LOGFILE}"
			${ECHO}
			${ECHO} "###### WARNING ######"
			${ECHO} "Errors reported during AutoMySQLBackup execution.. Backup failed"
			${ECHO} "Error log below.."
			${CAT} "${LOGERR}"
	else
		${CAT} "${LOGFILE}"
	fi	
fi

if [ -s "${LOGERR}" ]
	then
		STATUS=1
	else
		STATUS=0
fi

# Clean up Logfile
eval ${RM} -f "${LOGFILE}"
eval ${RM} -f "${LOGERR}"

rm /srv/www/kuhpatenschaft/forbidden/auto.lock 

exit ${STATUS}
