{
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix ./laptop.nix ./networking];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LUKS time?
  boot.initrd.systemd.enable = true;

  boot.supportedFilesystems = ["ntfs"];

  networking.hostName = "zweilous";

  # group moment
  users.users.stone.extraGroups = ["libvirtd" "dialout"];

  # gpg time?
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome";
  };

  # trying steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
      "veracrypt" # also veracrypt
    ];

  # man pages + python ig?
  environment.systemPackages = [pkgs.man-pages pkgs.man-pages-posix pkgs.python3 pkgs.veracrypt];
  documentation.dev.enable = true;

  # we do a little virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.podman.enable = true;
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "overlay";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };
  };

  system.stateVersion = "23.11";
}