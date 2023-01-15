{
  pkgs,
  lib,
  ...
}: {
  imports = [./users ./graphical.nix ./wifi.nix];

  time.timeZone = "America/Los_Angeles";

  networking.firewall.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [vis git exa ripgrep];
  environment.variables = {EDITOR = "vis";};

  boot.cleanTmpDir = lib.mkDefault true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];

      # for direnv
      keep-outputs = true;
      keep-derivations = true;

      substituters = ["https://nix-community.cachix.org/"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = ["wheel"];
        noPass = false;
        keepEnv = true;
      }
    ];
  };

  # command-not-found doesn't work with flakes; use nix-index instead
  # (configured in home-manager)
  programs.command-not-found.enable = false;

  nixpkgs.config.allowUnfree = true;
}
