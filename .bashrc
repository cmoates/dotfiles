# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Color escape sequences for prompt
COLOR_BOLD_GREEN='\033[01;32m'
COLOR_BOLD_BLUE='\033[01;34m'
COLOR_RESET='\033[00m'
COLOR_BLUE='\033[0;34m'

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# unlimited history size in current shell
HISTSIZE=-1
# big history file
HISTFILESIZE=100000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\['$COLOR_BOLD_GREEN'\]\u@\h\['$COLOR_RESET'\]:\['$COLOR_BOLD_BLUE'\]\w\['$COLOR_RESET'\]$(_config_status_prompt) \$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Silently fetch updates for the dotfiles bare repo in the background
(config fetch origin main &> /dev/null &)

# Function to show git dotfiles remote status in prompt (this is for the dotfiles repo only)
_config_status_prompt() {
    # Check if we are behind the remote
    local behind=$(config rev-list --count main..origin/main 2>/dev/null)
    if [ "$behind" -gt 0 ]; then
        # Return a warning symbol (e.g., a blue down arrow)
        echo -e " $COLOR_BLUE↓$behind$COLOR_RESET"
    fi
}

# Load direnv if installed
eval "$(direnv hook bash)"