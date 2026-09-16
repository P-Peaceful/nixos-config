{ pkgs, ... }:

let
  # 将雾凇拼音的官方 Rime 数据合并进 Fcitx5-Rime 的共享数据目录。
  # 其中包含官方 schema、中文/英文词库、Emoji/OpenCC 和 Lua 扩展。
  fcitx5RimeWithIce = pkgs.fcitx5-rime.override {
    rimeDataPkgs = [ pkgs.rime-ice ];
  };
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-fluent
      fcitx5RimeWithIce
    ];
  };
}
