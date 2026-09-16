{
  programs.fish.enable = true;

  # Fish 模块会生成自己的主配置，这里把个人交互配置作为 conf.d 文件维护。
  xdg.configFile."fish/conf.d/10-personal.fish".source = ./config.fish;
}
