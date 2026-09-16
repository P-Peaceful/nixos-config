{ pkgs, ... }:

{
  home.packages = with pkgs; [
    curl
    fd
    ripgrep
    tree
    vim
    wget
  ];
}

