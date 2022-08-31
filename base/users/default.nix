{ config, pkgs, ... }: {
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  users.users.stone = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOClmVzgghnkYd7nkLra97lhrdP+f524c3yz6uebBrjJ stone@solosis"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+3IqZFhMmrsjR67EnLwPDxfioaQ5r0ZXzA5/1IXR0I stone@simulacrum"
    ];
  };

  home-manager.users.stone = import ./stone;
}
