let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/c92939889627636e62f7c8c01d29b2a2e462f56f.tar.gz") {};
in
  pkgs.mkShell {
    name = "example-4-env";
    buildInputs = with pkgs; [
      R
      rPackages.dplyr
      rPackages.ggplot2
      rPackages.lme4
      rPackages.Matrix
    ];
   shellHook = ''
             printf "\n\nWelcome to example-4-env shell :)\n\n"
      '';
  }
