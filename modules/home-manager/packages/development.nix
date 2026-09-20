{ inputs, pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    pkgs.gcc
    pkgs.gnumake
    
    pkgs.go
    pkgs.jdk
    pkgs.maven3
    pkgs-unstable.jetbrains.datagrip
    pkgs-unstable.jetbrains.goland
    pkgs-unstable.jetbrains.idea

    pkgs.pkg-config
    pkgs.vscode
    pkgs.python3

    pkgs.nodejs_24
    pkgs.pnpm_11

  ];
}
