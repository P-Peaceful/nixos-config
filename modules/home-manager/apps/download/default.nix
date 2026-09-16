{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gopeed
  ];
}
