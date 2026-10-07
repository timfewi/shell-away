{
  inputs.nixpkgs.url = "@nixpkgs-url@";
  outputs = { nixpkgs, ... }: {
    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.writeShellApplication {
          name = "shell-away-session";
          runtimeInputs = with pkgs; [
            zsh
            starship
            eza
            ripgrep
            fd
            fzf
            bat
            git
            rsync
            zoxide
            ncurses
          ];
          text = ''
            export TERMINFO_DIRS="${pkgs.ncurses}/share/terminfo''${TERMINFO_DIRS:+:$TERMINFO_DIRS}"
            exec sh "$SHELL_AWAY_SESSION/bootstrap.sh" existing
          '';
        };
      }
    );
  };
}
