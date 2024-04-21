{
  imports = [
    ./hardware-configuration.nix
  ];

  # caddy stuff
  networking.firewall.allowedTCPPorts = [80 443];
  services.caddy = {
    enable = true;

    globalConfig = ''
      email domain@formulaic.cloud
    '';

    virtualHosts."formulaic.cloud".extraConfig = ''
      encode zstd gzip

      root * /srv/home/
      file_server

      @notstatic not path /static/*
      rewrite @notstatic /index.html
    '';
  };

  zramSwap.enable = true;
  networking.hostName = "altaria";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.useNetworkd = true;

  # inspired by https://github.com/NixOS/nixpkgs/blob/4a42c797a4d989674182f7b061221bb2ad9ea49d/nixos/modules/virtualisation/oci-common.nix
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    device = "nodev";
    splashImage = null;

    extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
    efiInstallAsRemovable = true;
    efiSupport = true;
  };

  boot.kernelParams = [
    "nvme.shutdown_timeout=10"
    "nvme_core.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"

    # VNC console
    "console=tty1"

    # x86_64-linux
    "console=ttyS0"

    # aarch64-linux
    "console=ttyAMA0,115200"
  ];

  boot.growPartition = true;

  system.stateVersion = "23.05";
}
