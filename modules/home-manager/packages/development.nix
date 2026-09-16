{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    gnumake
    pkg-config
    vscode
    python3
  ];
}

