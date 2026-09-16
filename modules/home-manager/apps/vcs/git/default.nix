{ pkgs, ... }:

{
  home.packages = [ pkgs.git ];
  xdg.configFile."git/config".source = ./config;
}

