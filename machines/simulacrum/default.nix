{config, ...}: {
  imports = [./hardware-configuration.nix];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "simulacrum";

  networking.interfaces.enp0s4.useDHCP = true;

  # PG-13 bot configuration
  age.secrets.pg13-config.file = ./secrets/pg13-config.age;

  services.pg-13.enable = true;
  services.pg-13.configFile = config.age.secrets.pg13-config.path;

  system.stateVersion = "21.05";
}
