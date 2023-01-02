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
      SIGNUPS_ALLOWED = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    virtualHosts.klefki = {
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:8000";
      };
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  system.stateVersion = "22.11";
}
