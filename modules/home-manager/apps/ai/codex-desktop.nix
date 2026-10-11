{
  programs.codexDesktopLinux = {
    enable = true;
    # 默认使用桌面应用自带的官方 Codex CLI
    linuxFeatures = [ ];
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
  };
}
