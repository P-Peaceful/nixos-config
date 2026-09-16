{ pkgs, ... }:

{
  # Install Flatpak applications system-wide so the desktop entries generated
  # by Flatpak (which invoke `flatpak run` without `--user`) resolve correctly.
  environment.systemPackages = [ pkgs.flatpak ];

  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Flatpak 应用及其用户级 overrides 由 Home Manager 统一管理。
    # 这里保留系统级 Flatpak 服务和 flathub remote，但不再在 system
    # installation 中重复安装同一批应用。
    packages = [ ];

    # Keep manually installed applications and remotes intact.
    uninstallUnmanaged = false;
  };
}
