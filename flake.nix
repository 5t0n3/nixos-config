{
  description = "My totally not cursed NixOS configurations :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # wayland :)
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # secret management
    agenix = {
      url = "github:ryantm/agenix";
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
    hyprpaper,
    agenix,
    pg-13,
  } @ inputs: let
    hostSystem = "x86_64-linux";
    mkSystem = import ./modules/flake/mk-system.nix inputs;
    hostPkgs = nixpkgs-unstable.legacyPackages.${hostSystem};
    deployNodes = {
      simulacrum = "simulacrum.localdomain";
      nacli = "nacli.localdomain";
      altaria = "10.0.0.10";
    };
    deployScripts = import ./modules/flake/deploy-scripts.nix hostPkgs deployNodes;
  in {
    nixosConfigurations = {
      zweilous = mkSystem {
        pkgs-input = inputs.nixpkgs-unstable;
        extraModules = [./modules/system/desktop ./machines/zweilous];
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

            exec-once = [
              "waybar &"
              "hyprpaper &"
            ];
          };

          programs.git = {
            userName = "Zane";
            userEmail = "git@formulaic.cloud";

            # sure let's sign everything, why not :) (this time with SSH)
            extraConfig = {
              commit.gpgSign = true;
              gpg.format = "ssh";
              user.signingKey = "~/.ssh/id_ed25519";
            };
          };

          # I think git needs this for signing?
          services.ssh-agent.enable = true;

          stone.programs.all = true;

          home.stateVersion = "23.11";
        };
      };

      simulacrum = mkSystem {
        extraModules = [pg-13.nixosModules.default ./machines/simulacrum];
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

      altaria = mkSystem {
        extraModules = [./machines/altaria];
        stoneConfig = {
          home.stateVersion = "23.11";
        };
      };
    };

    devShells.${hostSystem}.default = hostPkgs.mkShell {
      NIX_SSHOPTS = "-t";
      packages =
        [
          agenix.packages.${hostSystem}.agenix
          hostPkgs.alejandra
        ]
        ++ deployScripts;
    };

    formatter.${hostSystem} = hostPkgs.alejandra;
  };
}
