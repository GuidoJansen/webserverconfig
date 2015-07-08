#!/bin/bash

# USERNAME username
# DOMAIN domain
# TLD top level domain
# PASSWDSSH Password for SSH
# PASSWDSQL Password for Mysql

if [ $(id -u) -ne 0 ]; then
  echo "Only root may add a user to the system"
  exit 1
fi 

read -p "Enter customer name : " USER_NAME



# read -p "Enter user's email address : " USER_EMAIL
#read -s -p "Enter user's mysql password : " PASSWDSQL
PASSWDSQL=<PASSWORD>
PASSWDSSH=<PASSWORD>
#echo ""
# read -s -p "Enter root's mysql password : " ROOT_PASSWDSQL
# echo ""
USER_EMAIL="user@example.com"
ROOT_PASSWDSQL="<PASSWORD>"
HOSTNAME="$USER_NAME.localhost"
A2SITE_FILE="/etc/apache2/sites-available/$HOSTNAME"
LOGROTATE_FILE="/etc/logrotate.d/$HOSTNAME"
SITE_PATH="/var/www/$HOSTNAME"

ROTATELOGS=$(which rotatelogs)

# ----
# Linux user
# ----
# creates user $USER_NAME and group $USER_NAME
useradd -U -M $USER_NAME
# echo "$PASSWDSSH" | passwd $USER_NAME --stdin
echo "$USER_NAME:$PASSWDSSH" | chpasswd

echo "cp -R ./skeleton $SITE_PATH"
cp -R ./skeleton $SITE_PATH

#mkdir $SITE_PATH
#mkdir $SITE_PATH/htdocs

# changes owner and group of directory recursively
# chown -R $USER_NAME:$UR_NAME $Swww-data:www-data the home directory of user $USER_NAME
usermod -d $SITE_PATH $USER_NAME

# changes the login shell of user $USER_NAME
usermod -s /bin/bash $USER_NAME

#echo "User $USER_NAME created."


source create/apache

echo "<h1>$USERNAME OK</h1>" > $SITE_PATH/htdocs/index.html
source create/.profile
source create/.tigrc
source create/logrotate



# Restarts Apache
# /etc/init.d/apache2 restart
# Activates Virtual Host
a2ensite $HOSTNAME
# Restarts Apache
/etc/init.d/apache2 restart

## Create log file dir
#mkdir $SITE_PATH/log
#chown $USER_NAME:$USER_NAME $SITE_PATH/log
#chmod 700 $SITE_PATH/log
#
## Create old log file dir
#mkdir $SITE_PATH/log/old
#chown $USER_NAME:$USER_NAME $SITE_PATH/log/old
#chmod 700 $SITE_PATH/log/old
#
## create error log file
#touch $SITE_PATH/log/error.log
#chown $USER_NAME:$USER_NAME $SITE_PATH/log/error.log
#chmod 600 $SITE_PATH/log/error.log

# create access log file
#touch $SITE_PATH/log/access.log
#chown $USER_NAME:$USER_NAME $SITE_PATH/log/access.log
#chmod 600 $SITE_PATH/log/access.log


# changes owner and group of directory recursively
chown -R $USER_NAME:$USER_NAME $SITE_PATH

# changes permissions of every directory and file in directory to drwxrwx--- resp. -rw-rw----
find $SITE_PATH -type d | xargs chmod 0770
find $SITE_PATH -type f | xargs chmod 0660

echo "Subdomain $HOSTNAME created." 


# ----
# SQL
# ---

#Creates user $USER_NAME with password
mysql -p$ROOT_PASSWDSQL -e "CREATE USER '$USER_NAME'@'localhost' IDENTIFIED BY '$PASSWDSQL';"

# creates databes $USER_NAME
mysql -p$ROOT_PASSWDSQL -e "CREATE DATABASE `$USER_NAME`;"

# changes user permission
mysql -p$ROOT_PASSWDSQL -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,LOCK TABLES ON `$USER_NAME`.* TO '$USER_NAME'@'localhost';"

echo "MySQL user $USER_NAME created."

echo "--ok";


