{
  description = "My totally not cursed NixOS configurations :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Display-related stuff
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Config-specific stuff
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.utils.follows = "flake-utils";
    };

    # Testing
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    pg-13 = {
      url = "github:5t0n3/pg-13";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    home-manager,
    nix-index-db,
    nixos-wsl,
    nixpkgs-wayland,
    hyprland,
    hyprpaper,
    agenix,
    deploy-rs,
    nix-alien,
    pg-13,
  } @ inputs: let
    system = "x86_64-linux";
    mkSystem = extraModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          [
            agenix.nixosModules.age
            home-manager.nixosModules.home-manager
            hyprland.nixosModules.default
            pg-13.nixosModules.default
            {
              # Provide flake inputs to regular & home-manager config modules
              _module.args = {inherit inputs;};
              home-manager.extraSpecialArgs = {inherit inputs;};

              # Include git revision of config in nixos-verison output
              system.configurationRevision =
                nixpkgs.lib.mkIf (self ? rev) self.rev;

              # pin <nixpkgs> path & registry entry to current nixos-unstable rev
              nix.nixPath = ["nixpkgs=${inputs.nixpkgs-unstable}"];
              nix.registry.nixpkgs.flake = inputs.nixpkgs-unstable;
            }
            ./base
          ]
          ++ extraModules;
      };
    mkNode = host: hostConfig: {
      hostname = "${host}.localdomain";
      fastConnection = true;

      profiles.system = {
        sshUser = "root";
        path = deploy-rs.lib.${system}.activate.nixos hostConfig;
      };
    };
    unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
  in {
    nixosConfigurations = {
      cryogonal = mkSystem [
        ./machines/cryogonal
        ({pkgs, ...}: {
          # nix-alien setup for testing
          programs.nix-ld.enable = true;
          environment.systemPackages = [
            (nix-alien.packages.${pkgs.system}.nix-alien.overridePythonAttrs (_: {
              doCheck = false;
            }))
          ];
        })
      ];

      solosis = mkSystem [./machines/solosis];

      simulacrum = mkSystem [./machines/simulacrum];

      spiritomb =
        mkSystem [nixos-wsl.nixosModules.wsl ./machines/spiritomb.nix];

      klefki = mkSystem [./machines/klefki];
    };

    # Not every machine has to be deployed to (e.g. cryogonal is where I deploy from)
    deploy.nodes = let
      isDeployed = name: _: builtins.elem name ["simulacrum" "klefki"];
      configs = nixpkgs.lib.filterAttrs isDeployed self.nixosConfigurations;
    in
      builtins.mapAttrs mkNode configs;

    devShells.${system}.default = unstablePkgs.mkShell {
      # alejandra is included so it doesn't get garbage collected (?)
      packages = [
        agenix.packages.${system}.agenix 
        deploy-rs.packages.${system}.deploy-rs 
        unstablePkgs.alejandra
        unstablePkgs.nil
      ];
    };

    formatter.${system} = unstablePkgs.alejandra;

    # taken directly from deploy-rs repo
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
