{
  xdg.configFile = {
    "fcitx5/profile".source = ./profile;
    "fcitx5/config".source = ./config;
    "fcitx5/conf/classicui.conf".source = ./classicui.conf;
    "fcitx5/conf/rime.conf".source = ./rime.conf;
  };

  # Fcitx5 主题属于用户级配置，直接放入用户数据目录。
  # 其中 mint-green-light 是“碧皓青”。
  xdg.dataFile = {
    "fcitx5/themes/macOS-light".source = ./themes/macOS-light;
    "fcitx5/themes/macOS-light-png".source = ./themes/macOS-light-png;
    "fcitx5/themes/mint-green-light".source = ./themes/mint-green-light;
    # 只声明个人覆盖；雾凇拼音官方 schema、词库、Lua 和 OpenCC 数据
    # 由 NixOS 的 fcitx5-rime 共享数据包提供，避免复制一份到用户目录。
    "fcitx5/rime/default.custom.yaml".source = ./rime/default.custom.yaml;
  };
}
