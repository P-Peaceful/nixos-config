{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    gnumake
    
    go
    jdk
    maven3
    jetbrains.datagrip
    jetbrains.goland
    jetbrains.idea

    pkg-config
    vscode
    python3

    nodejs_24
    pnpm_11

  ];
}
