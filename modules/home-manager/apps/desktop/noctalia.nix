{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;

    # 将 Noctalia Settings 中导出的个人配置作为声明式基础配置。
    # ~/.local/state/noctalia/settings.toml 仍作为可写的 GUI 覆盖层保留。
    settings = ./noctalia-config.toml;
  };
}
