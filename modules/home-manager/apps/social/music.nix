{ inputs, pkgs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    pkgs.listen1
    pkgs.splayer
  ];
}
