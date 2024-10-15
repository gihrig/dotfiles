#export JAVA_HOME=$(/usr/libexec/java_home)
#export CATALINA_HOME=/Library/Tomcat
#export ANT_HOME=/usr/share/ant
#export ROO_HOME=/Applications/Development/DevelopmentFolders/STS.3.0/spring-roo-1.2.2.RELEASE
#export ROO_OPTS="-Droo.bright=true"
export TERM_PROGRAM="Apple_Terminal"
export MYSQL_HOME=/usr/local/mysql
#export MAVEN_HOME=/usr/bin/mvn
#xport RBENV_ROOT=/usr/local/var/rbenv
#if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
#xport rvmsudo_secure_path=1

#export CATALINA_OPTS="-Dfile.encoding=utf-8"
#export JAVA_OPTS="-Dfile.encoding=iso-8859-1"
#export JAVA_OPTS="-Dfile.encoding=utf-8"

export NODE_PATH=src # Required for Storybook to resolve `import X from 'components/X'`

# Suggested by brew install nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Shell support for fzf
# bash
# eval "$(fzf --bash)"

# zsh
source <(fzf --zsh)


# Path
#export PATH=$JAVA_HOME/bin:$PATH
#export PATH=$ROO_HOME/bin:$PATH
export PATH=$MYSQL_HOME/bin:$PATH
#export PATH=/usr/local/mongodb/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH
export PATH="/library/PostgreSQL/13/bin:$PATH"

# Docker
# eval "$(docker-machine env default)"

# Aliases
alias sha256='shasum --portable -a 256' # Usage: "sha256 myfile" or "echo -n your_desired_password | sha256" see man shasum
alias sha512='shasum --portable -a 512' # Usage: "sha512 myfile" or "echo -n your_desired_password | sha512" see man shasum
#alias roo='roo.sh'

alias backup='~/arkScripts/arkDump.sh'
alias restore='~/arkScripts/arkLoad.sh'
alias prepbk='source ~/iczScripts/prepbk.sh'
alias dump='~/iczScripts/iczDump.sh'
alias load='~/iczScripts/iczLoad.sh'
alias nginxctl='~/iczScripts/iczNginx.sh'
alias gitrev='~/iczScripts/gitrev.sh'
alias chkcollection='~/iczScripts/iczChkCollection.sh'

alias ejectall='~/ejectall.sh'
alias stack='./stack.sh'

alias cra='create-react-app'
alias cna='create-next-app'

alias stats='git diff --stat HEAD^ HEAD'

alias surrealdb='~/surrealdb.sh'
alias sqlite='sqlite3'

alias e2e-test='cargo leptos end-to-end'
alias e2e-release='cargo leptos end-to-end --release'
alias e2e-report='open ./end2end/playwright-report/index.html'

# maintained by HomeBrew
export PATH="/opt/homebrew/bin/:$PATH"

. "$HOME/.cargo/env"
