{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # 亮度快捷键
    brightnessctl
    # 媒体快捷键
    playerctl
    # 锁屏快捷键
    swaylock
    wl-clipboard
    # nix 语言格式化
    nixfmt
  ];
}
