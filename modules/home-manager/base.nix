{
  home.username = "wenzhengcheng";
  home.homeDirectory = "/home/wenzhengcheng";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  programs.bash.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "google-chrome";
    NIXOS_OZONE_WL = "1";
  };
}
