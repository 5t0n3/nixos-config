{
  description = "My totally not cursed NixOS configurations :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # wayland :)
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # my stuff
    pg-13 = {
      url = "github:5t0n3/pg-13";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    home-manager-unstable,
    nix-index-db,
    nixos-wsl,
    hyprland,
    hyprpaper,
    agenix,
    deploy-rs,
    pg-13,
  } @ inputs: let
    hostSystem = "x86_64-linux";
    mkSystem = import ./modules/flake/mkSystem.nix inputs;
    hostPkgs = nixpkgs-unstable.legacyPackages.${hostSystem};
    deployNodes = ["simulacrum" "nacli"];
    deployScripts = import ./modules/flake/deploy-scripts.nix hostPkgs deployNodes;
    mkNode = host: hostConfig: {
      hostname = "${host}.localdomain";
      fastConnection = true;

      profiles.system = {
        sshUser = "root";
        # TODO: unhack system attr
        path = deploy-rs.lib.${hostSystem}.activate.nixos hostConfig;
      };
    };
  in {
    nixosConfigurations = {
      cryogonal = mkSystem {
        pkgs-input = inputs.nixpkgs-unstable;
        extraModules = [./modules/system/desktop ./machines/cryogonal];
        # extraModules = [./machines/cryogonal];
        stoneConfig = {
          stone.wm.enable = true;
          stone.wm.hyprland.extraSettings = {
            monitor = [
              "eDP-1,2560x1600,2560x1200,1" # laptop screen
              "DP-1,2560x1440,0x0,1" # home - external monitor
              ",preferred,5120x1200,1" # position all other monitors to right of laptop screen
            ];

            # workspace bindings
            workspace = [
              "eDP-1, 1"
              "DP-1, 2"
              "DP-1, 3"
            ];
          };

          home.stateVersion = "22.05";
        };
      };

      simulacrum = mkSystem {
        extraModules = [pg-13.nixosModules.default ./machines/simulacrum];
        stoneConfig = {
          home.stateVersion = "22.05";
        };
      };

      spiritomb = mkSystem {
        pkgs-input = inputs.nixpkgs-unstable;
        extraModules = [nixos-wsl.nixosModules.wsl ./machines/spiritomb.nix];
        stoneConfig = {
          home.stateVersion = "22.05";
        };
      };

      nacli = mkSystem {
        extraModules = [./machines/nacli];
        stoneConfig = {
          home.stateVersion = "23.05";
        };
      };
    };

    # TODO: make less hacky
    deploy.nodes = let
      isDeployed = name: _: builtins.elem name ["simulacrum" "klefki"];
      configs = nixpkgs.lib.filterAttrs isDeployed self.nixosConfigurations;
    in
      builtins.mapAttrs mkNode configs;

    devShells.${hostSystem}.default = hostPkgs.mkShell {
      NIX_SSHOPTS = "-t";
      packages =
        [
          agenix.packages.${hostSystem}.agenix
          hostPkgs.alejandra
          deploy-rs.packages.${hostSystem}.deploy-rs
        ]
        ++ deployScripts;
    };

    # as advised in the deploy-rs readme
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    formatter.${hostSystem} = hostPkgs.alejandra;
  };
}
