{ pkgs, lib, ... }:

{
  imports = [ ./users ./graphical.nix ./wifi.nix ];

  time.timeZone = "America/Los_Angeles";

  networking.firewall.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [ vis git exa ripgrep ];
  environment.variables = { EDITOR = "vis"; };

  boot.cleanTmpDir = lib.mkDefault true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      # for direnv
      keep-outputs = true;
      keep-derivations = true;

      substituters = [ "https://nix-community.cachix.org/" ];
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

  nixpkgs.config.allowUnfree = true;
}
