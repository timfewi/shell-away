{
  lib,
  formats,
  runCommand,
  writeText,
  writeShellApplication,
  openssh,
  gnutar,
  coreutils,
  aliases ? import ./src/aliases.nix,
  starshipSettings ? import ./src/prompt.nix,
}:
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsNode = lock.nodes.${lock.nodes.root.inputs.nixpkgs};
  # The target resolves only this public Nixpkgs revision, never this flake.
  remoteLock = {
    version = 7;
    root = "root";
    nodes = {
      root.inputs.nixpkgs = "nixpkgs";
      nixpkgs = nixpkgsNode;
    };
  };
  remoteFlake = writeText "shell-away-flake.nix" (
    lib.replaceStrings
      [ "@nixpkgs-url@" ]
      [ "github:${nixpkgsNode.locked.owner}/${nixpkgsNode.locked.repo}/${nixpkgsNode.locked.rev}" ]
      (builtins.readFile ./src/remote-flake.nix)
  );
  aliasFile = writeText "shell-away-aliases.sh" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: value:
        let
          command = builtins.head (lib.splitString " " value);
        in
        "if command -v ${lib.escapeShellArg command} >/dev/null 2>&1; then alias ${lib.escapeShellArg "${name}=${value}"}; fi"
      ) aliases
    )
    + "\n"
  );
  prompt = (formats.toml { }).generate "shell-away-starship.toml" starshipSettings;
  lockFile = writeText "shell-away-flake.lock" (builtins.toJSON remoteLock);
  bundle = runCommand "shell-away-session" { } ''
    mkdir -p "$out"
    cp ${./src/bootstrap.sh} "$out/bootstrap.sh"
    cp ${./src/init.sh} "$out/init.sh"
    cp ${aliasFile} "$out/aliases.sh"
    cp ${prompt} "$out/starship.toml"
    cp ${remoteFlake} "$out/flake.nix"
    cp ${lockFile} "$out/flake.lock"
    printf '%s\n' '. "$SHELL_AWAY_SESSION/init.sh"' > "$out/.zshrc"
  '';
in
writeShellApplication {
  name = "shell-away";
  runtimeInputs = [
    openssh
    gnutar
    coreutils
  ];
  text = ''
    bundle_dir=${lib.escapeShellArg (toString bundle)}
  ''
  + builtins.readFile ./src/shell-away.sh;
  passthru = { inherit bundle; };
  meta = {
    description = "Open a temporary shell over SSH using the target's available tools";
    homepage = "https://github.com/timfewi/shell-away";
    license = lib.licenses.mit;
    mainProgram = "shell-away";
    platforms = lib.platforms.linux;
  };
}
