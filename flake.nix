{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";

    pg-13 = {
      url = "github:5t0n3/pg-13";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, nixos-wsl, hyprland, pg-13 }:
    let
      mkSystem = extraModules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.age
            home-manager.nixosModules.home-manager
            hyprland.nixosModules.default
            pg-13.nixosModules.default
            ./base
            ({
              system.configurationRevision =
                nixpkgs.lib.mkIf (self ? rev) self.rev;
            })
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = {
        cryogonal = mkSystem [ ./machines/cryogonal ];

        solosis = mkSystem [
          ./machines/solosis

          # PG-13 development
          # TODO: use containers instead?
          ({ config, ... }: {
            age.secrets.pg13-config = {
              file = ./machines/solosis/secrets/pg13-devconfig.age;
              path = "/var/lib/pg-13/config.toml";
              owner = "pg-13";
              group = "pg-13";
            };

            services.pg-13.enable = true;
          })
        ];

        simulacrum = mkSystem [ ./machines/simulacrum ];

        spiritomb =
          mkSystem [ nixos-wsl.nixosModules.wsl ./machines/spiritomb.nix ];
      };

      devShells.x86_64-linux.default =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in pkgs.mkShell {
          packages = [ agenix.packages.x86_64-linux.agenix pkgs.nixfmt ];
        };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
