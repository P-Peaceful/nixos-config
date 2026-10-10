{ pkgs, ...}:
{

  networking.networkmanager.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
