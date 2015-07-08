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



#read -p "Enter user's email address : " USER_EMAIL
USER_EMAIL="gjansen@coco-new-media.de"
#read -s -p "Enter user's mysql password : " PASSWDSQL
PASSWDSQL="coco12"
#echo ""
#read -s -p "Enter root's mysql password : " ROOT_PASSWDSQL
ROOT_PASSWDSQL="s7rk7r-d"
#echo ""

HOSTNAME="$USER_NAME.localhost"
A2SITE_FILE="/etc/apache2/sites-available/$HOSTNAME"
LOGROTATE_FILE="/etc/logrotate.d/$HOSTNAME"
SITE_PATH="/var/www/$HOSTNAME"

ROTATELOGS=$(which rotatelogs)

# ----
# Linux user
# ----
# creates user $USER_NAME and group $USER_NAME
#useradd -U -M $USER_NAME
# echo "$PASSWDSSH" | passwd $USER_NAME --stdin
#echo "$USER_NAME:$PASSWDSSH" | chpasswd

#echo "cp -R /var/www/skeleton $SITE_PATH"
cp -R /var/www/skeleton $SITE_PATH

#mkdir $SITE_PATH
#mkdir $SITE_PATH/htdocs

# changes owner and group of directory recursively
chown -R www-data:www-data $SITE_PATH

# changes the home directory of user $USER_NAME
#usermod -d $SITE_PATH $USER_NAME

# changes the login shell of user $USER_NAME
#usermod -s /bin/bash $USER_NAME

#echo "User $USER_NAME created."


source /root/create/apache

echo "<h1>$USERNAME OK</h1>" > $SITE_PATH/htdocs/index.html
#cat <<EOF > $SITE_PATH/.profile
#if [ '$SSH_TTY' ]
#then
#	echo '                                               '
#	echo '-----------------------------------------------'
#	echo 'This account uses some aliases for abbreviation'
#	echo '-----------------------------------------------'
#	echo 'git status               : gst                 '
#	echo 'git commit               : gc                  '
#	echo 'git commit -a            : gca                 '
#	echo 'git add                  : ga                  '
#	echo 'git checkout             : gco                 '
#	echo 'git checkout -b          : gcb                 '
#	echo 'git branch               : gb                  '
#	echo 'git merge                : gm                  '
#	echo 'git stash                : gs                  '
#	echo 'git stash save           : gss                 '
#	echo 'git stash list           : gsl                 '
#	echo 'git log --pretty=oneline : glo                 '
#	echo '-----------------------------------------------'
#	echo '                                               '
#
#	alias gst='git status '
#	alias gc='git commit '
#	alias gca='git commit -a '
#	alias ga='git add '
#	alias gco='git checkout '
#	alias gcb='git checkout -b '
#	alias gb='git branch '
#	alias gm='git merge '
#	alias gs='git stash '
#	alias gss='git stash save '
#	alias gsl='git stash list '
#	alias glo='git log --pretty=oneline '
#
#	source /etc/bash_completion.d/git-completion.bash
#	source /etc/bash_completion.d/git-prompt.sh
#
#	PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\\\\\$ "'
#fi
#EOF

#echo "
#set show-author = abbreviated
#set show-date = relative
#set show-rev-graph = yes
#
#
#set line-graphics = ascii
#
#color default           white   black
#color date       white	default
## Diff colors
#
#color graph-commit	magenta	default
##color graph	red	default
#color main-head        magenta default
#color main-tag        red default
#
## vim: set expandtab sw=4 tabstop=4:
## *color* 'area' 'fgcolor' 'bgcolor' '[attributes]'
#
## general
#color   default                 15      235
#color   cursor                  15      241
#color   title-focus             242     221
#color   title-blur              242     221
#color   delimiter               213     default
#color   author                  156     default
#color   date                    81      default
#color   line-number             221     default
#color   mode                    255     default
#
## main
#color   main-tag                213     default     bold
#color   main-local-tag          213     default
#color   main-remote             221     default
#color   main-replace            81      default
#color   main-tracked            221     default     bold
#color   main-ref                81      default
#color   main-head               213     default     bold
#color   graph-commit            226     default
#color   main_revgraph           81      default
#
## status
##color  stat-head       81      default
#
## Diff   colors
#color   diff_add                10      default
#color   diff_add2               10      default
#color   diff_del                196     default
#color   diff_del2               196     default
#color   diff-header             221     default
#color   diff-index              81      default
#color   diff-chunk              213     default
#color   diff_oldmode            221     default
#color   diff_newmode            221     default
#color   diff_deleted_file_mode  221     default
#color   diff_copy_from          223     default
#color   diff_copy_to            221     default
#color   diff_rename_from        221     default
#color   diff_rename_to          221     default
#color   diff_similarity         221     default
#color   diff_dissimilarity      221     default
#color   diff_tree               81      default
#color   diff-stat               81      default
#color   'Reported-by:'          156     default
#
#color   pp-author               156     default
#color   pp-commit               213     default
#color   pp-adate                221     default
#color   pp-cdate                221     default
#color   pp-date                 81      default
#color   pp_refs                 213     default
#color   palette-0               226     default
#color   palette-1               213     default
#color   palette-2               118     default
#color   palette-3               51      default
#color   palette-4               196     default
#color   palette-5               219     default
#color   palette-6               190     default
#
## status
#color   stat_head               221     default
#color   stat_section            81      default
#color   stat_staged             213     default
#color   stat_unstaged           213     default
#color   stat_untracked          213     default
#
## raw commit header
#color   commit                  156     default
#color   committer               213     default
#
## commit message
#color   signoff                 221     default
#color   acked                   221     default
#color   tested                  221     default
#color   reviewed                221     default
#
## tree
#color   tree-dir                221     default
#
## LINE(PALETTE_0, "", COLOR_MAGENTA, COLOR_DEFAULT, 0), \
##   LINE(PALETTE_1, "", COLOR_YELLOW, COLOR_DEFAULT, 0), \
##   LINE(PALETTE_2, "", COLOR_CYAN, COLOR_DEFAULT, 0), \
##   LINE(PALETTE_3, "", COLOR_GREEN, COLOR_DEFAULT, 0), \
##   LINE(PALETTE_4, "", COLOR_DEFAULT, COLOR_DEFAULT, 0), \
##   LINE(PALETTE_5, "", COLOR_WHITE, COLOR_DEFAULT, 0), \
##   LINE(PALETTE_6, "", COLOR_RED, )
#
#" > $SITE_PATH/.tigrc


source /root/create/logrotate



# Restarts Apache
/etc/init.d/apache2 restart
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
chown -R www-data:www-data $SITE_PATH

# changes permissions of every directory and file in directory to drwxrwx--- resp. -rw-rw----
find $SITE_PATH -type d | xargs chmod 0770
find $SITE_PATH -type f | xargs chmod 0660

echo "Subdomain $HOSTNAME created." 


source /root/create/mysql

