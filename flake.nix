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
    # 加密
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nix-flatpak, sops-nix, ... }:
    let
      system = "x86_64-linux";
      userName = "wenzhengcheng";

      commonModules = [
        ./modules/security/sops
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
      ];

      mkHost = {
        hostname,
        hostModules,
        homeModule,
      }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs userName hostname;
          };

          modules = hostModules ++ commonModules ++ [
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                extraSpecialArgs = {
                  inherit inputs userName hostname;
                };

                users.${userName} = {
                  imports = [
                    nix-flatpak.homeManagerModules.nix-flatpak
                    homeModule
                  ];
                };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations.thinkbook14 = mkHost {
        hostname = "thinkbook14";
        hostModules = [ ./hosts/thinkbook14 ];
        homeModule = ./hosts/thinkbook14/home.nix;
      };
    };
}
