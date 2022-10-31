{ config, ... }:

{
  imports = [ ./hardware-configuration.nix ./networking ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" "ntfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Required to get graphics working
  boot.extraModprobeConfig = ''
    options i915 force_probe=46a6
    options i915 force_probe=5693
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
    options = [ "rw" "uid=1000" ];
  };

  hardware.cpu.intel.updateMicrocode = true;

  stone.graphical = true;

  services.xserver = {
    xkbOptions = "caps:swapescape";
    xrandrHeads = [
      # laptop screen
      "eDP-1"

      # external monitor through thunderbolt
      {
        output = "DP-1";
        primary = true;
        monitorConfig = ''
          Option "LeftOf" "eDP-1"
        '';
      }
    ];
  };

  system.stateVersion = "22.05";
}

