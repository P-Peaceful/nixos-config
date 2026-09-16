{ pkgs, ... }:

{
  # 使用接近 Windows 默认风格的光标主题，并同时覆盖 GTK/XWayland 应用。
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk.enable = true;

  # niri 本体由 NixOS 模块启用；配置文件由 Home Manager 管理。
  xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;
}
