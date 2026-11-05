{ lib, pkgs, ... }:

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

  home.packages = [ pkgs.loupe ];

  # 显式关联图片格式，避免默认使用浏览器打开。
  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.genAttrs [
      "image/apng"
      "image/avif"
      "image/bmp"
      "image/gif"
      "image/heic"
      "image/jp2"
      "image/jpeg"
      "image/jxl"
      "image/png"
      "image/qoi"
      "image/svg+xml"
      "image/svg+xml-compressed"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
      "image/x-dds"
      "image/x-exr"
      "image/x-portable-anymap"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
      "image/x-portable-pixmap"
      "image/x-qoi"
      "image/x-tga"
      "image/x-win-bitmap"
      "image/x-xbitmap"
      "image/x-xpixmap"
    ] (_: [ "org.gnome.Loupe.desktop" ]);
  };

  # niri 本体由 NixOS 模块启用；配置文件由 Home Manager 管理。
  xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;
}
