{ pkgs, lib, ... }:

{
  imports = [ ./users ./graphical.nix ./wifi.nix ];

  time.timeZone = "America/Los_Angeles";

  networking.useDHCP = false;
  networking.firewall.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [ vis git exa ripgrep ];
  environment.variables = { EDITOR = "vis"; };

  boot.cleanTmpDir = lib.mkDefault true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nix = {
    # Enable flakes support
    package = pkgs.nixFlakes;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
