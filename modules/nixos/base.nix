{ pkgs, ... }:

{
  # 使用 GRUB2 管理 UEFI 启动项；ESP 挂载在 /boot。
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    # 双系统：在 GRUB 菜单中探测 Windows Boot Manager。
    useOSProber = true;
    # GRUB 启动菜单使用 Catppuccin Mocha 主题。
    theme = pkgs.catppuccin-grub.override {
      flavor = "mocha";
    };
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # 闭源桌面客户端不会总是携带中文字体，统一安装 CJK 字体解决 QQ 音乐
  # 中文文本显示为方框或空白的问题。
  fonts.packages = with pkgs; [
    # QQ 音乐使用 Electron 12，旧版 Chromium 对可变 TTC 字体回退不稳定；
    # 使用静态 TTC，避免中文 glyph 被渲染为 tofu。
    noto-fonts-cjk-sans-static
    noto-fonts-cjk-serif-static
    noto-fonts-color-emoji
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  users.users.wenzhengcheng = {
    isNormalUser = true;
    description = "wenzhengcheng";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  system.stateVersion = "26.05";
}
