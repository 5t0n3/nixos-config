{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" "ntfs" ];

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
  networking.interfaces.wlp0s20f3.useDHCP = true;

  hardware.cpu.intel.updateMicrocode = true;

  stone.graphical = true;

  system.stateVersion = "22.05";
}

