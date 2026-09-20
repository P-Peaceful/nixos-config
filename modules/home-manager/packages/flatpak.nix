{ pkgs, ... }:

{
  home.packages = [
    pkgs.flatpak
  ];
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      { appId = "com.tencent.WeChat"; origin = "flathub"; }
    ];

    overrides = {
      # 微信新版在 Wayland 输入前端下无法可靠切换 Fcitx 输入上下文。
      # 强制使用 XWayland 后，Fcitx5 的 XIM/Qt 路径可以正常工作。
      "com.tencent.WeChat" = {
        Context.sockets = [ "x11" "!wayland" "!fallback-x11" ];
        Environment = {
          GTK_IM_MODULE = "fcitx";
          QT_IM_MODULE = "fcitx";
          SDL_IM_MODULE = "fcitx";
          XMODIFIERS = "@im=fcitx";
          QT_QPA_PLATFORM = "xcb";
          # 不要把 NixOS 主机的 Qt 插件搜索路径带进 Flatpak 沙箱。
          QT_PLUGIN_PATH = "";
          TZ = "Asia/Shanghai";
        };
      };
    };

    # 默认不删除通过命令行或软件中心手动安装的 Flatpak。
    uninstallUnmanaged = true;
  };
}
