{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "simulacrum";

  networking.interfaces.enp0s4.useDHCP = true;

  # PG-13 bot configuration
  age.secrets.pg13-config = {
    file = ./secrets/pg13-config.age;
    path = "/var/lib/pg-13/config.toml";
    owner = "pg-13";
    group = "pg-13";
  };

  services.pg-13.enable = true;

  system.stateVersion = "21.05";
}

