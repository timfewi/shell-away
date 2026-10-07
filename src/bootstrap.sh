#!/bin/sh
set -eu

if [ "${1:-existing}" = nix ]; then
  nix_bin=$(command -v nix || :)
  if [ -z "$nix_bin" ]; then
    for candidate in "$HOME/.nix-profile/bin/nix" /nix/var/nix/profiles/default/bin/nix; do
      if [ -x "$candidate" ]; then
        nix_bin=$candidate
        break
      fi
    done
  fi
  if [ -z "$nix_bin" ]; then
    printf 'shell-away: --nix requires Nix on the target; nothing was installed.\n' >&2
    exit 69
  fi
  nix_system=$("$nix_bin" --extra-experimental-features 'nix-command flakes' \
    eval --impure --raw --expr builtins.currentSystem)
  case "$nix_system" in
  x86_64-linux | aarch64-linux | aarch64-darwin) ;;
  x86_64-darwin)
    printf 'shell-away: the pinned Nixpkgs no longer supports Intel macOS. Use existing-tools mode without --nix.\n' >&2
    exit 69
    ;;
  *)
    printf 'shell-away: unsupported Nix platform: %s\n' "$nix_system" >&2
    exit 69
    ;;
  esac
  unset ENV BASH_ENV ZDOTDIR
  exec "$nix_bin" --extra-experimental-features 'nix-command flakes' run \
    --no-write-lock-file --no-update-lock-file "path:$SHELL_AWAY_SESSION#default"
fi

# The outer SSH command owns the directory and waits until this shell exits.
unset ENV BASH_ENV ZDOTDIR
export TERM=xterm-256color
if command -v infocmp >/dev/null 2>&1; then
  for terminal in xterm-256color xterm vt100; do
    if infocmp "$terminal" >/dev/null 2>&1; then
      TERM=$terminal
      break
    fi
  done
  if ! infocmp "$TERM" >/dev/null 2>&1; then
    printf 'shell-away: no usable terminal definition found.\n' >&2
    exit 69
  fi
fi
export TERM
export STARSHIP_CONFIG="$SHELL_AWAY_SESSION/starship.toml"
export STARSHIP_CACHE="$SHELL_AWAY_SESSION/starship-cache"
export _ZO_DATA_DIR="$SHELL_AWAY_SESSION/zoxide"
SHELL_AWAY_HOST=$(uname -n)
export SHELL_AWAY_HOST

if command -v zsh >/dev/null 2>&1; then
  export SHELL_AWAY_KIND=zsh
  SHELL=$(command -v zsh)
  export SHELL
  export ZDOTDIR="$SHELL_AWAY_SESSION"
  exec "$SHELL" -d -i
elif command -v bash >/dev/null 2>&1; then
  export SHELL_AWAY_KIND=bash
  SHELL=$(command -v bash)
  export SHELL
  exec "$SHELL" --noprofile --rcfile "$SHELL_AWAY_SESSION/init.sh" -i
else
  export SHELL_AWAY_KIND=sh
  SHELL=$(command -v sh)
  export SHELL
  export ENV="$SHELL_AWAY_SESSION/init.sh"
  exec "$SHELL" -i
fi
