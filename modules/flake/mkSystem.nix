inputs: let
  mkSystem = {
    pkgs-input ? inputs.nixpkgs,
    extraModules ? [],
    system ? "x86_64-linux",
    stoneConfig ? {},
  }: let
    hm-input =
      if pkgs-input == inputs.nixpkgs
      then inputs.home-manager
      else inputs.home-manager-unstable;
  in
    pkgs-input.lib.nixosSystem {
      inherit system;
      modules =
        [
          hm-input.nixosModules.default
          inputs.agenix.nixosModules.age
          inputs.hyprland.nixosModules.default
          inputs.nix-index-db.nixosModules.nix-index

          # flake plumbing (config rev, nix path)
          (import ./plumbing.nix inputs pkgs-input)

          # base system config
          ../system/base

          # single-user home-manager config
          {
            home-manager.users.stone = {
              imports = [
                ../home
              ];

              config = stoneConfig;
            };
          }
        ]
        ++ extraModules;
    };
in
  mkSystem
