{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # 桌面登录会话也能找到 mise 工具，供 IDEA、Git hooks 等非交互进程使用。
  home.sessionPath = [ "${config.xdg.dataHome}/mise/shims" ];

  # 仅管理兼容性设置，保留 config.toml 可写，允许 mise use -g 修改版本。
  xdg.configFile."mise/conf.d/10-nixos.toml".source = ./nixos.toml;

  # 首次激活时提供默认版本；已有配置和后续手动修改均不覆盖。
  home.activation.miseDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mise_config=${lib.escapeShellArg "${config.xdg.configHome}/mise/config.toml"}
    if [ ! -e "$mise_config" ] && [ ! -L "$mise_config" ]; then
      run ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg "${config.xdg.configHome}/mise"}
      run ${pkgs.coreutils}/bin/install -m 644 ${./config.toml} "$mise_config"
    fi
  '';
}
