# Sourced by zsh, bash or a POSIX interactive shell, never the login profile.
unset HISTFILE
# shellcheck disable=SC1091
. "$SHELL_AWAY_SESSION/aliases.sh"

# Eza versions and BSD/GNU ls accept different flags. Probe a single file,
# never enumerate the current directory while constructing the environment.
if command -v eza >/dev/null 2>&1 &&
  eza --long --all --group-directories-first --icons=auto --header --git -- /dev/null >/dev/null 2>&1; then
  : # Keep the shared eza aliases.
else
  if ls --group-directories-first -ld . >/dev/null 2>&1; then
    alias l='ls -lah --group-directories-first'
    alias ll='ls -lah --group-directories-first'
  elif ls -lahd . >/dev/null 2>&1; then
    alias l='ls -lah'
    alias ll='ls -lah'
  else
    alias l='ls -la'
    alias ll='ls -la'
  fi
  unalias lt 2>/dev/null || :
fi

case "$SHELL_AWAY_KIND" in
zsh)
  HISTSIZE=1000
  export SAVEHIST=0
  unsetopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY PROMPT_SUBST
  setopt AUTO_CD INTERACTIVE_COMMENTS
  autoload -Uz compinit
  compinit -D
  bindkey -e
  PS1='%m:%~ [%?] %# '
  alias reload='exec "$SHELL" -d -i'
  ;;
bash)
  HISTSIZE=1000
  HISTFILESIZE=0
  shell_away_prompt() {
    shell_away_status=$?
    PS1='\h:\w ['"$shell_away_status"'] \$ '
  }
  PROMPT_COMMAND=shell_away_prompt
  alias reload='exec "$SHELL" --noprofile --rcfile "$SHELL_AWAY_SESSION/init.sh" -i'
  ;;
sh)
  PS1='${SHELL_AWAY_HOST}:${PWD} [$?] $ '
  alias reload='exec "$SHELL" -i'
  ;;
esac

if [ "$SHELL_AWAY_KIND" != sh ]; then
  if command -v fzf >/dev/null 2>&1; then
    if shell_away_integration=$(fzf "--$SHELL_AWAY_KIND" 2>/dev/null); then
      eval "$shell_away_integration"
    fi
  fi
  if command -v zoxide >/dev/null 2>&1; then
    if shell_away_integration=$(zoxide init "$SHELL_AWAY_KIND" 2>/dev/null); then
      eval "$shell_away_integration"
    fi
  fi
  if command -v starship >/dev/null 2>&1; then
    if shell_away_integration=$(starship init "$SHELL_AWAY_KIND" 2>/dev/null); then
      eval "$shell_away_integration"
    fi
  fi
fi
unset shell_away_integration
