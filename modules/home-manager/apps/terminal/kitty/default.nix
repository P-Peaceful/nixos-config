{ pkgs, ... }:

{
  home.packages = [ 
    pkgs.kitty
    pkgs.termius
  ];
  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;
}

