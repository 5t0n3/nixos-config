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
  users.users.stone.extraGroups = ["libvirtd" "dialout" "docker"];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      # encryption of removable drives
      "veracrypt"

      # steam-related stuff
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
    ];

  # man pages + python ig?
  environment.systemPackages = [pkgs.man-pages pkgs.man-pages-posix pkgs.python3 pkgs.veracrypt pkgs.docker-compose];
  documentation.dev.enable = true;

  # we do a little virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # don't really care about non-x86 architectures
      package = pkgs.qemu_kvm;

      # emulated tpms wowow
      swtpm.enable = true;

      ovmf = {
        enable = true;
        packages = let
          binbowsOVMF = pkgs.OVMF.override {
            # I love microsoft
            msVarsTemplate = true;
            secureBoot = true;
            tpmSupport = true;
          };
        in [
          binbowsOVMF.fd
        ];
      };
    };
  };
  programs.virt-manager.enable = true;

  virtualisation.podman.enable = true;
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "overlay";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };
  };

  # can't get rid of docker yet :(
  virtualisation.docker.enable = true;

  # steam ig
  programs.steam.enable = true;

  # testing out systemd idle stuff?
  services.logind = {
    powerKey = "suspend"; # defaults to `poweroff`
    # suspend after 10 minutes (since laptop monitor never recovers from hyprland dpms)
    # idk if this actually works but hopefully swayidle does something here
    # extraConfig = ''
    #   IdleAction=suspend
    #   IdleActionSec=600
    # '';
  };

  # tailscaleeee
  services.tailscale.enable = true;

  system.stateVersion = "23.11";
}
