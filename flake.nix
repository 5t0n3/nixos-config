{
  description = "My totally not cursed NixOS configurations :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    # Testing
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
    home-manager-unstable,
    nix-index-db,
    nixos-wsl,
    nixpkgs-wayland,
    hyprland,
    hyprpaper,
    agenix,
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
    # hack for if I decide to not go full unstable
    mkUnstableSystem = extraModules:
      nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        modules =
          [
            agenix.nixosModules.age
            home-manager-unstable.nixosModules.home-manager
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
    unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
    # TODO: move to separate file?
    deployNodes = ["simulacrum" "klefki"];
    deployList = unstablePkgs.lib.concatMapStringsSep "\n" (str: " - " + str) deployNodes;
    deployRegex = "(${unstablePkgs.lib.concatStringsSep "|" deployNodes})";
    deploy-sh = unstablePkgs.writeShellApplication {
      name = "deploy";

      runtimeInputs = builtins.attrValues {
        inherit (unstablePkgs) nixos-rebuild gnugrep git nix-output-monitor;
      };
      text = ''
        # basic usage cause why not
        if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
          echo "Usage: deploy <host> [-f]"
          echo "Deployment targets:"
          echo "${deployList}"
        # ensure a valid host was provided
        elif echo "$1" | grep -qvE "${deployRegex}"; then
          echo "Please specify a valid deployment host! Your choices are:"
          echo "${deployList}"
        # clean working tree deployment
        elif git diff-index --quiet HEAD; then
          revstr=$(git rev-parse --short HEAD)
          printf "Deploying configuration version \e[0;92m%s\e[0m to \e[1;97m%s\e[0m!\n" "$revstr" "$1"
          nixos-rebuild switch --target-host "$1.localdomain" --fast --use-remote-sudo --flake ".#$1" |& nom
        # Forced dirty deployment with fancy colors :)
        elif [ $# -eq 2 ] && [ "$2" = "-f" ]; then 
          printf "\e[1;91mWARNING!\e[0m"
          printf " Deploying uncommitted configuration version to \e[1;97m%s\e[0m!\n" "$1"
          nixos-rebuild switch --target-host "$1.localdomain" --fast --use-remote-sudo --flake ".#$1" |& nom
        # dirty working tree warning
        else
          echo "Commit your changes before deploying! (or provide the -f flag)"
        fi
      '';
    };
  in {
    nixosConfigurations = {
      cryogonal = mkUnstableSystem [
        ./machines/cryogonal
      ];

      solosis = mkSystem [./machines/solosis];

      simulacrum = mkSystem [./machines/simulacrum];

      spiritomb =
        mkSystem [nixos-wsl.nixosModules.wsl ./machines/spiritomb.nix];

      klefki = mkSystem [./machines/klefki];
    };

    devShells.${system}.default = unstablePkgs.mkShell {
      NIX_SSHOPTS = "-t";
      # alejandra is included so it doesn't get garbage collected (?)
      packages = [
        agenix.packages.${system}.agenix
        unstablePkgs.alejandra
        unstablePkgs.nil
        deploy-sh
      ];
    };

    formatter.${system} = unstablePkgs.alejandra;
  };
}
