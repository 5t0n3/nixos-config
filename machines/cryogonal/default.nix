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
  # boot.extraModprobeConfig = ''
  #   options i915 force_probe=5693
  # '';

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
  boot.initrd.kernelModules = ["i915"];

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

  # group moment
  users.users.stone.extraGroups = ["libvirtd" "dialout"];
  users.users.stone.packages = [pkgs.gh];

  # we do a little virtualization (also man pages)
  virtualisation.libvirtd.enable = true;
  documentation.dev.enable = true;
  environment.systemPackages = [pkgs.virt-manager inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.distrobox pkgs.man-pages pkgs.man-pages-posix pkgs.podman-compose];
  virtualisation.podman.enable = true;
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "zfs";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };
  };

  # distrobox moment
  security.sudo.enable = lib.mkForce true;

  # hardware key login maybe?
  security.pam.u2f.enable = true;
  security.pam.u2f.interactive = true;
  security.pam.u2f.cue = true;

  system.stateVersion = "22.05";
}
