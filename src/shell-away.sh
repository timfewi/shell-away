# The package supplies bundle_dir; keep the transport separate from remote code.
usage() {
  cat <<'EOF'
Usage: shell-away [--tailscale] [--nix] HOST

Open a temporary shell on a Linux or macOS SSH target.
Use SSH configuration for usernames, ports, keys and jump hosts.

  --tailscale  Connect using the installed tailscale ssh wrapper.
  --nix        Use existing remote Nix to fetch the pinned standard tools.
  -h, --help   Show this help.

Default: use available zsh, bash or sh and existing tools without downloads.
Session configuration is removed on normal exit and handled signals.
Nix packages and state written by other programs may remain on the target.
EOF
}

target=
mode=existing
use_tailscale=false
while (($#)); do
  case "$1" in
  --nix) mode=nix ;;
  --tailscale) use_tailscale=true ;;
  -h | --help)
    usage
    exit 0
    ;;
  -*)
    printf 'shell-away: unknown option: %s\n' "$1" >&2
    exit 64
    ;;
  *)
    if [[ -n "$target" ]]; then
      printf 'shell-away: expected exactly one SSH target.\n' >&2
      exit 64
    fi
    target=$1
    ;;
  esac
  shift
done
if [[ -z "$target" ]]; then
  usage >&2
  exit 64
fi
target_pattern='^([a-zA-Z0-9_.@:%-]|\[|\])+$'
if [[ ! "$target" =~ $target_pattern ]]; then
  printf 'shell-away: invalid SSH target. Use an SSH configuration alias or user@host.\n' >&2
  exit 64
fi
if "$use_tailscale" && ! command -v tailscale >/dev/null 2>&1; then
  printf 'shell-away: --tailscale requires tailscale in PATH.\n' >&2
  exit 69
fi

# Only the seven generated, non-secret assets enter the payload.
: "${bundle_dir:?shell-away bundle is unavailable}"
payload=$(tar --format=ustar --blocking-factor=1 -C "$bundle_dir" -cf - \
  bootstrap.sh init.sh aliases.sh starship.toml flake.nix flake.lock .zshrc | base64 -w 0)

bootstrap=$(
  cat <<'SH'
umask 077
for tool in uname mktemp rm tar base64 sh; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'shell-away: missing bootstrap tool: %s\n' "$tool" >&2
    exit 69
  fi
done
case $(uname -s) in
  Linux|Darwin) ;;
  *) printf 'shell-away: only Linux and macOS targets are supported.\n' >&2; exit 69 ;;
esac
session=$(mktemp -d "${TMPDIR:-/tmp}/shell-away.XXXXXXXX") || exit 73
cleanup() { rm -rf -- "$session"; }
trap cleanup 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
decode() {
  if printf '' | base64 -d >/dev/null 2>&1; then
    base64 -d
  else
    base64 -D
  fi
}
SH
)
bootstrap+=$'\n'
bootstrap+="printf '%s' '$payload' | decode | tar -xf - -C \"\$session\" || exit 74"
bootstrap+=$'\n'
# The variable must expand on the target, not on the client.
# shellcheck disable=SC2016
bootstrap+='export SHELL_AWAY_SESSION="$session"'
bootstrap+=$'\n'
bootstrap+="sh \"\$session/bootstrap.sh\" '$mode'"

# SSH transmits a command string, not a remote argv array. POSIX-quote it once.
quote() { printf "'%s'" "${1//\'/\'\\\'\'}"; }
remote_command="exec sh -c $(quote "$bootstrap")"
command_bytes=$(LC_ALL=C printf '%s' "$remote_command" | wc -c)
if ((command_bytes > 32768)); then
  printf 'shell-away: configuration exceeds the 32 KiB remote-command limit (%s bytes).\n' "$command_bytes" >&2
  exit 65
fi

export TERM=xterm-256color
ssh_options=(-tt -a -x -o ClearAllForwardings=yes -o 'SendEnv=-*'
  -o ServerAliveInterval=15 -o ServerAliveCountMax=3)
if "$use_tailscale"; then
  exec tailscale ssh "$target" "${ssh_options[@]}" "$remote_command"
else
  exec ssh "${ssh_options[@]}" "$target" "$remote_command"
fi
