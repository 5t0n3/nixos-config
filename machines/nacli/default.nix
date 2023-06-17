{
  config,
  pkgs,
  inputs,
  ...
}:
let
  vaultwarden-latest = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.vaultwarden;
in {
  imports = [
    ./hardware-configuration.nix
    ./fail2ban.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nacli";

  services.openssh.settings.PasswordAuthentication = false;

  age.secrets.vaultwarden-env = {
    file = ./secrets/vaultwarden-env.age;
    path = "/var/lib/vaultwarden.env";
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    package = vaultwarden-latest;
    webVaultPackage = vaultwarden-latest.webvault;
    environmentFile = config.age.secrets.vaultwarden-env.path;
    config = {
      DOMAIN = "https://vault.othman.io";
      SIGNUPS_ALLOWED = false;
      IP_HEADER = "X-Forwarded-For";

      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8016;

      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_PORT = 3012;

      SMTP_HOST = "smtp.gmail.com";
      SMTP_FROM = "cuber.zee@gmail.com";
      SMTP_USERNAME = "cuber.zee@gmail.com";
      SMTP_PORT = 465;
      SMTP_SECURITY = "force_tls";
    };
  };

  networking.firewall.allowedTCPPorts = [3012 8016];

  hardware.cpu.intel.updateMicrocode = true;

  system.stateVersion = "23.05";
}
