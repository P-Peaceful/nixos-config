{ pkgs, ... }:

{
  # 支持 mise 下载的通用 Linux 运行时和常见原生扩展。
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libffi
      libxcrypt
      ncurses
      readline
      sqlite
    ];
  };
}
