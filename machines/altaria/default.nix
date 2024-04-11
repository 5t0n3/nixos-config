{
  imports = [
    ./hardware-configuration.nix
    # TODO: oci-common?
  ];

  zramSwap.enable = true;
  networking.hostName = "altaria";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.useNetworkd = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  system.stateVersion = "23.05";
}
