{ pkgs, ... }:

{
  # # 微信 Linux 桌面客户端。
  # home.packages = [ pkgs.wechat ];

  # # 覆盖软件包自带的 wechat.desktop。微信使用 XCB 时需要显式加载
  # # Fcitx5 Qt 输入法插件；变量只作用于微信，不影响其他 Qt/GTK 应用。
  # xdg.dataFile."applications/wechat.desktop".source = ./wechat.desktop;
}
