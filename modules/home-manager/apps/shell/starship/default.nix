{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  # Starship 原生 TOML 跟随 Starship 应用维护，不把提示符内容写进 Nix。
  xdg.configFile."starship.toml".source = ./starship.toml;
}
