# shell-away

Open a temporary, adapted interactive shell on a Linux or macOS SSH target
without installing or changing anything there.

```sh
nix run github:timfewi/shell-away -- user@host
```

Or add the package to a flake-based configuration with one line:

```nix
home.packages = [ shell-away.packages.${pkgs.stdenv.hostPlatform.system}.default ];
```

## Usage

```text
shell-away [--tailscale] [--nix] HOST
```

- `HOST` is an SSH configuration alias or `user@host`. Use SSH configuration
  for ports, identity files and jump hosts.
- `--tailscale` connects through the installed `tailscale ssh` wrapper.
- `--nix` uses Nix that is already installed on the target to provide pinned
  zsh, Starship, Eza, Ripgrep, fd, Fzf, Bat, Git, Rsync and Zoxide. Only the
  public Nixpkgs input is needed on the target. The wrapper never installs Nix,
  activates profiles or updates lockfiles; Nix can download or build packages
  and they stay in its store after the session ends.

The default mode downloads nothing. The target needs a POSIX shell, `uname`,
`mktemp`, `rm`, `tar` and `base64`.

## What the session looks like

The wrapper selects zsh, Bash, then sh and loads a separate temporary
configuration. The target's `HOME` is kept. Bash and zsh enable Starship, Fzf
and Zoxide when they exist; the fallback prompt shows hostname, directory and
exit status. Listing aliases adapt to the available Eza or BSD/GNU `ls`.
Global startup files can still run. This environment is not a sandbox.

## What is transferred and kept

Only generated, non-secret shell assets are sent, within a 32 KiB limit for
the complete remote command. No local history, credentials, environment or
desktop configuration is copied.

Session files live in a private temporary directory that is removed on normal
exit and handled signals. History is kept in memory, and Starship cache and
Zoxide state are redirected into the session directory. Other commands can
write their own state and the SSH server can record sessions. A network
failure takes time to detect; `SIGKILL` or power loss can leave temporary
files. Agent, X11 and port forwarding are disabled. Windows targets are not
supported.

## Customize

`package.nix` is a `callPackage` function. Override the generated assets:

```nix
shell-away.override {
  aliases = { ll = "ls -l"; };
  starshipSettings = { format = "$hostname$directory$character"; };
}
```

## Development

```sh
nix develop
just test    # transports, shells, fallbacks, signals and cleanup (local fixtures)
just check   # fast gate: format, lint, tests
just build   # build the package
```

## License

[MIT](LICENSE)
