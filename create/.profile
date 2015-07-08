echo "
if [ '$SSH_TTY' ]
then
	echo '                                               '
	echo '-----------------------------------------------'
	echo 'This account uses some aliases for abbreviation'
	echo '-----------------------------------------------'
	echo 'git status               : gst                 '
	echo 'git commit               : gc                  '
	echo 'git commit -a            : gca                 '
	echo 'git add                  : ga                  '
	echo 'git checkout             : gco                 '
	echo 'git checkout -b          : gcb                 '
	echo 'git branch               : gb                  '
	echo 'git merge                : gm                  '
	echo 'git stash                : gs                  '
	echo 'git stash save           : gss                 '
	echo 'git stash list           : gsl                 '
	echo 'git log --pretty=oneline : glo                 '
	echo '-----------------------------------------------'
	echo '                                               '

	alias gst='git status '
	alias gc='git commit '
	alias gca='git commit -a '
	alias ga='git add '
	alias gco='git checkout '
	alias gcb='git checkout -b '
	alias gb='git branch '
	alias gm='git merge '
	alias gs='git stash '
	alias gss='git stash save '
	alias gsl='git stash list '
	alias glo='git log --pretty=oneline '

	source /etc/bash_completion.d/git-completion.bash
	source /etc/bash_completion.d/git-prompt.sh

	PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\\\\\$ "'
fi
" > $SITE_PATH/.profile