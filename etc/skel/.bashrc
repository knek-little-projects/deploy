#!/bin/bash
export DISPLAY=:1
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1001/bus
export XDG_RUNTIME_DIR=/run/user/1001
export XAUTHORITY=/run/user/1001/gdm/Xauthority
export PATH=$PATH:$HOME/.local/bin

PROMPT_COMMAND='echo -ne "\033]0;$(pwd) | $(whoami)\007"'

alias soundcontrol=pavucontrol
alias A='apt-get update && apt-get dist-upgrade'
alias su='su -l'
alias l='ls -lashrt --color=always'
alias ..='cd ..;l'
alias less='less -I'
alias grep='grep --color=always'
alias free='free -h'
alias df='df -h'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias mplayer='mplayer -loop 0'
alias feh='feh -F'
alias cal='ncal -b -M -y'
alias x='xdg-open'
alias X='xterm'
alias св='cd'
alias ьм='mv'
alias д='l'
alias юю='..'
alias ll='ls -l --color=always'
alias r='stat -c "%a %n"'


ipclear() {
  for table in filter nat mangle; do
    iptables -t $table -F
  done
}

export QUOTING_STYLE=literal
export HISTFILESIZE=
export HISTSIZE=

se() {
    medit "$@" &
}

nullify() {
    if [ ! -z "$1" ] && lsblk "$1"
    then
        printf "Are you really sure you want to ERASE $1 (y/N)? "
        read answer
        if [[ $answer == y ]]
        then
            echo "You asked for this!"
            time dd status=progress of=/dev/zero of="$1"
        fi
    fi
}

httpredirect() {
  length=$(($#-1))
  array=${@:1:$length}
  dest=${@: -1}
  for address in $array; do
    iptables -t nat -A OUTPUT -p tcp -d $address --dport 80 -j DNAT --to-destination $dest
    iptables -t nat -A OUTPUT -p tcp -d $address --dport 443 -j DNAT --to-destination $dest
  done
}

ipblock() {
  for address in $*; do
    iptables -A OUTPUT -d ${address} -j REJECT
  done
}

a() {
  alert "$(history | tail -n1)"
}

mkpy() {
  echo '#!/usr/bin/env python3' > "$1" && \
  chmod +x "$1" && \
  l "$1"
}

-() {
    cd "$@"; l;
}

speak() {
    if [ -z "$1" ]
    then
        espeak done
    else
        espeak "$@"
    fi
}

i() {
    ts_file=~/tmp/apt-get-update.ts
    ts_new=$(date +%s)
    if [ -f ${ts_file} ]
    then
        ts_old=$(grep -oE '[0-9]+' ${ts_file})
    else
        ts_old=0
    fi
    if [ $((ts_new - ts_old)) -gt 3600 ]
    then
        apt-get update
        printf "%d" ${ts_new} > ${ts_file}
    fi
    apt-get install -y "$@"
}

ovpn() {
    if [ -z $1 ]
    then
        cd ~/.ovpn
    else
        cd $1
    fi
    xterm -e "openvpn --daemon --script-security 2 --config *.ovpn;" &
}

upow() {
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep perc | grep -oE [0-9]+. | sed -r s/100\%//
}

iter() {
    while sleep 1
    do
        "$@"
    done
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

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;${PSC}\]\A\[\033[00m\]:\[\033[01;${PSC}\]$(upow)\[\033[00m\]:\[\033[01;${PSC}\]\u\[\033[00m\]:\[\033[01;${PSC}\]\w\[\033[00m\]$(psc_branch)\$ '

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export LESS='-R'
export LESSOPEN='|pygmentize %s'

dump() {
    local t="$HOME/dump/$(date +%s)"
    mkdir -p "$t"
    if [[ $# == 0 ]]; then
        cd "$t"
    else
        mv "$@" "$t"
    fi
}

copydump() {
    local t="$HOME/dump/$(date +%s)"
    mkdir -p "$t"
    if [[ $# == 0 ]]; then
        cd "$t"
    else
        cp -r "$@" "$t"
    fi
}
