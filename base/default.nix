{
  pkgs,
  lib,
  ...
}: {
  imports = [./users ./graphical.nix];

  time.timeZone = "America/Los_Angeles";

  networking.firewall.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [vis helix du-dust git exa ripgrep];
  environment.variables = {EDITOR = "hx";};

  boot.tmp.cleanOnBoot = lib.mkDefault true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "stone"];

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

  # doas <3
  # security.sudo.enable = false;
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

  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  # command-not-found doesn't work with flakes; use nix-index instead
  # (configured in home-manager)
  programs.command-not-found.enable = false;

  nixpkgs.config.allowUnfree = true;
}
