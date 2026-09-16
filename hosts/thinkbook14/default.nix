{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/hardware.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/apps/flatpak.nix
    ../../modules/nixos/apps/input-method.nix
    ../../modules/nixos/desktop/gdm.nix
    ../../modules/nixos/desktop/gnome.nix
    ../../modules/nixos/desktop/niri.nix
  ];

  networking.hostName = "nixos";
}
