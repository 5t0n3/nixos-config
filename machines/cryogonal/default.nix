{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix ./networking];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = ["zfs" "ntfs"];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Required to get graphics working
  boot.extraModprobeConfig = ''
    options i915 force_probe=46a6,5693
  '';

  networking.hostName = "cryogonal";

  # ZFS settings
  networking.hostId = "c1d359ee";
  services.zfs = {
    trim.enable = true;
    autoSnapshot.enable = true;
    autoScrub.enable = true;
  };

  # Mount windows partition
  fileSystems."/mnt/windows" = {
    device = "/dev/nvme0n1p3";
    fsType = "ntfs";
    options = ["rw" "uid=1000"];
  };

  hardware.cpu.intel.updateMicrocode = true;

  # Wayland time :)
  stone.graphical.enable = true;
  stone.graphical.type = "wayland";

  # taken from nixos-hardware
  services.fstrim.enable = true; # yay ssds

  # intel graphics stuffs
  boot.initrd.kernelModules = [ "i915" ];

  environment.variables.VDPAU_DRIVER = "va_gl";

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    intel-media-driver
  ];

  # power management is a thing ig?
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 1;
    };
  };

  system.stateVersion = "22.05";
}
