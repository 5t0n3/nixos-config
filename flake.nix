{
  description = "My totally not cursed NixOS configurations :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    lix = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-1.tar.gz";
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
    lanzaboote,
    lix,
    hyprpaper,
    agenix,
    pg-13,
  } @ inputs: let
    hostSystem = "x86_64-linux";
    mkSystem = import ./modules/flake/mk-system.nix inputs;
    hostPkgs = nixpkgs-unstable.legacyPackages.${hostSystem};
    # deployNodes = {
    #   simulacrum = "simulacrum.localdomain";
    #   nacli = "nacli.localdomain";
    #   altaria = "10.0.0.10";
    # };
    # no other servers for now through series of unfortunate events
    deployNodes = {};
    deployScripts = import ./modules/flake/deploy-scripts.nix hostPkgs deployNodes;
  in {
    nixosConfigurations = {
      zweilous = mkSystem {
        pkgs-input = inputs.nixpkgs-unstable;
        extraModules = [
          lix.nixosModules.default
          ./modules/system/desktop
          ./machines/zweilous
        ];
        stoneConfig = {
          stone.wm.enable = true;
          stone.wm.hyprland.extraSettings = {
            monitor = [
              "eDP-1,preferred,auto,1" # laptop screen
              "DP-1,preferred,auto-left,1" # home - external monitor
              ",preferred,auto,1" # position all other monitors to right of laptop screen
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

      balls = mkSystem {
        pkgs-input = inputs.nixpkgs-unstable;
        extraModules = [
          lix.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          ./modules/system/desktop
          ./machines/balls
        ];
        stoneConfig = {
          stone.wm.enable = true;
          stone.wm.hyprland.extraSettings = {
            monitor = [
              ",preferred,auto,1" # position all other monitors to right of laptop screen
            ];

            exec-once = [
              "waybar &"
              "hyprpaper &"
            ];
          };

          stone.programs = {
            dev = true;
          };

          programs.zathura.enable = true;

          home.stateVersion = "25.11";
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
