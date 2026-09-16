{
  description = "Personal NixOS 26.05 configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia v5+ module and package.
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Flatpak management; pin the latest stable nix-flatpak release.
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = inputs@{ nixpkgs, home-manager, nix-flatpak, ... }: {
    nixosConfigurations.thinkbook14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        ./hosts/thinkbook14
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = { inherit inputs; };

            users.wenzhengcheng = {
              imports = [
                nix-flatpak.homeManagerModules.nix-flatpak
                ./hosts/thinkbook14/home.nix
              ];
            };
          };
        }
      ];
    };
  };
}
