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
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
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
    emacs-overlay,
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
      cryogonal = mkSystem [./machines/cryogonal];

      solosis = mkSystem [./machines/solosis];

      simulacrum = mkSystem [./machines/simulacrum];

      spiritomb =
        mkSystem [nixos-wsl.nixosModules.wsl ./machines/spiritomb.nix];

      klefki = mkSystem [./machines/klefki];
    };

    deploy.nodes = builtins.mapAttrs mkNode self.nixosConfigurations;

    devShells.${system}.default = unstablePkgs.mkShell {
      # alejandra is included so it doesn't get garbage collected (?)
      packages = [agenix.packages.${system}.agenix deploy-rs.packages.${system}.deploy-rs unstablePkgs.alejandra];
    };

    formatter.${system} = unstablePkgs.alejandra;

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
