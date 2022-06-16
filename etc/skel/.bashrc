#!/bin/bash
# export DISPLAY=:0
# export DBUS_SESSION_BUS_ADDRESS=unix:path=~
# export XDG_RUNTIME_DIR=~
# export XAUTHORITY=~/.Xauthority
export PATH=$PATH:$HOME/.local/bin:$HOME/.node_modules_global/bin
export QUOTING_STYLE=literal
export HISTFILESIZE=
export HISTSIZE=

PROMPT_COMMAND='echo -ne "\033]0;$(pwd) | $(whoami)\007"'

alias soundcontrol=pavucontrol
alias clip='xclip -sel clipip'
alias l='ls -lashrt --color=auto'
alias ..='cd ..;l'
alias less='less -I'
alias grep='grep --color=auto'
alias free='free -h'
alias df='df -h'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias feh='feh -F'
alias cal='ncal -b -M -y'
alias x='xdg-open'
alias X='xterm'
alias св='cd'
alias ьм='mv'
alias д='l'
alias юю='..'
alias p='git push'

c() {
  set -x -e
  git add .
  if [ $# -eq 0 ]; then
    git commit -m-
  else
    git commit -m "$*"
  fi
  set +x +e
}

-() {
    cd "$@"; l;
}

s() {
    "$@" 2>/dev/null 1>/dev/null &
}

if [ $(whoami) == root ]
then
    PSC="31m"

    xmount() {
      mount "$@" -o fmask=117,dmask=007,uid=x
    }
else
    if [ $(whoami) == x ]; then
        PSC="34m"
    else
        PSC="32m"
    fi

    alias I='iceweasel -P default --new-instance'
    alias C='chromium --incognito'
    alias C='google-chrome --incognito'
    alias tcpdump='echo no root'
    alias nmap='echo no root'
fi

psc_branch() {
    BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [[ -z "${BRANCH}" ]]
    then
        printf "" 
    elif git diff-index --quiet HEAD -- 2>/dev/null
    then
        printf ':\033[07;32m%s\033[00m' "${BRANCH}"
    else
        printf ':\033[07;31m%s (%s)\033[00m' "${BRANCH}" $(git config user.email)
    fi
}

_ps1_upow() {
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep perc | grep -oE [0-9]+. | sed -r s/100\%//
}

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;${PSC}\]\A\[\033[00m\]:\[\033[01;${PSC}\]$(_ps1_upow)\[\033[00m\]:\[\033[01;${PSC}\]\u\[\033[00m\]:\[\033[01;${PSC}\]\w\[\033[00m\]$(psc_branch)\$ '

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

dump() {
    local t="$HOME/dump/$(date +%s)"
    mkdir -p "$t"
    if [[ $# == 0 ]]; then
        cd "$t"
    else
        mv "$@" "$t"
    fi
}

if [ -d $HOME/.bashrc.d ] && [[ $(find $HOME/.bashrc.d -type f | wc -l) -gt 0 ]]; then
for f in $(ls -1 $HOME/.bashrc.d/*); do
  source $f
done
fi
