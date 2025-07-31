{ config, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6588090b-deb9-45fe-8053-02ef5a22f4e7";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  boot.initrd.luks.devices."inside".device = "/dev/disk/by-uuid/a6d9adbf-3659-4fcf-bb20-4f31309fc57b";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/6588090b-deb9-45fe-8053-02ef5a22f4e7";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/6588090b-deb9-45fe-8053-02ef5a22f4e7";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/6588090b-deb9-45fe-8053-02ef5a22f4e7";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/6588090b-deb9-45fe-8053-02ef5a22f4e7";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/6588090b-deb9-45fe-8053-02ef5a22f4e7";
      fsType = "btrfs";
      options = [ "subvol=swap" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6770-C3D0";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ 
    {
      device = "/swap/swapfile";
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
