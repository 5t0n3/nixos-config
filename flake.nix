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
      url = "git+https://git.lix.systems/lix-project/lix?ref=release-2.93";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=release-2.93";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.lix.follows = "lix";
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
    lix-module,
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
          lix-module.nixosModules.default
          ./modules/system/desktop
          ./machines/zweilous
        ];
        stoneConfig = {
          stone.wm.enable = true;
          stone.wm.hyprland.extraSettings = {
            # workspace bindings
            workspace = [
              "eDP-1, 1"
              "DP-1, 2"
              "DP-1, 3"
            ];
          };

          programs.git.settings.user = {
            name = "Zane";
            email = "git@formulaic.cloud";
          };

          services.ssh-agent.enable = true;

          stone.programs.all = true;

          services.remmina.enable = true;

          home.stateVersion = "23.11";
        };
      };

      balls = mkSystem {
        pkgs-input = inputs.nixpkgs-unstable;
        extraModules = [
          lix-module.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          ./modules/system/desktop
          ./machines/balls
        ];
        stoneConfig = {
          stone.wm.enable = true;

          stone.programs = {
            dev = true;
          };

          programs.zathura.enable = true;

          home.stateVersion = "25.11";
        };
      };
    };

    packages.${hostSystem}.installer = let
      installerSystem = nixpkgs-unstable.lib.nixosSystem {
        modules = [
          ({
            modulesPath,
            ...
          }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
            ];

            # TODO: parameterize? or not worth
            nixpkgs.hostPlatform = "x86_64-linux";
          })
          ./modules/system/base/users.nix
          ./modules/system/base/openssh.nix
        ];
      };
    in
      installerSystem.config.system.build.isoImage;

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
