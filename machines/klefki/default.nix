{config, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # zfs :)
  boot.supportedFilesystems = ["zfs"];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  services.zfs = {
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  networking.hostName = "klefki";
  networking.hostId = "82ad974d";

  services.openssh.passwordAuthentication = false;

  age.secrets.vaultwarden-env = {
    file = ./secrets/vaultwarden-env.age;
    path = "/var/lib/vaultwarden.env";
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden-env.path;
    config = {
      DOMAIN = "https://vault.othman.io";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 6666;

      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_PORT = 3012;
    };
  };

  networking.firewall.allowedTCPPorts = [3012 6666];

  hardware.cpu.intel.updateMicrocode = true;

  system.stateVersion = "22.11";
}
