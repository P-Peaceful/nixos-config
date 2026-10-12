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

    # 开发语言运行时、pnpm 和 Maven 统一由 mise 管理。
    pkgs-unstable.jetbrains.datagrip
    pkgs-unstable.jetbrains.goland
    pkgs-unstable.jetbrains.idea

    pkgs.pkg-config
    pkgs.vscode
    pkgs.docker
  ];
}
