{
pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./secureboot.nix
    ./networking.nix
    ./laptop.nix
  ];

  # support ntfs cause why not
  boot.supportedFilesystems = ["ntfs"];

  # le docs
  documentation.dev.enable = true;

  # containers
  virtualisation.podman.enable = true;

  # firmware
  services.fwupd.enable = true;

  # no ssh
  services.openssh.enable = lib.mkForce false;

  # bluetooth waow
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # le packages
  environment.systemPackages = lib.attrVals [
    # TODO: move these pages to base/desktop
    "man-pages"    
    "man-pages-posix"
    "whois"

    "python3"
  ] pkgs;

  system.stateVersion = "25.11";

  # TODO: specialisations?
}
