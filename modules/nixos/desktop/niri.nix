{ pkgs, ... }:

{
  programs.niri.enable = true;

  # niri 26.04+ 通过 xwayland-satellite 按需兼容 X11 应用。
  # 微信使用 QT_QPA_PLATFORM=xcb，QQ 音乐也可能依赖 X11，必须让该程序
  # 出现在 niri-session 的 PATH 中；否则它们在 GNOME 下能启动、niri 下却无窗口。
  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
