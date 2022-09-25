{ config, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" "ntfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Required to get graphics working
  boot.extraModprobeConfig = "options i915 force_probe=46a6\n";

  networking.hostName = "cryogonal";

  boot.cleanTmpDir = false;
  boot.tmpOnTmpfs = true;

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

  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  stone.wireless = {
    enable = true;
    interfaces = [ "wlp0s20f3" ];
  };

  systemd.network = {
    enable = true;
    networks = {
      "45-wl-dhcp" = {
        matchConfig.Name = "wl*";
        networkConfig.DHCP = "ipv4";
      };
    };
    wait-online.anyInterface = true;
  };

  hardware.cpu.intel.updateMicrocode = true;

  stone.graphical = true;

  system.stateVersion = "22.05";
}

