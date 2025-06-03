{
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix ./laptop.nix ./networking.nix];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # binbows
  boot.supportedFilesystems = ["ntfs"];

  # LUKS time
  boot.initrd.systemd.enable = true;

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

      # michaelsoft fonts
      "vista-fonts"
      "corefonts"
    ];

  # packages waow
  environment.systemPackages =
    lib.attrVals [
      "man-pages"
      "man-pages-posix"
      "python3"
      "veracrypt"
      "docker-compose"
      "signal-desktop"
      "whois"
    ]
    pkgs;
  documentation.dev.enable = true;

  # microsoft fonts :(
  fonts.packages = lib.attrVals ["vista-fonts" "corefonts"] pkgs;
  fonts.fontconfig.subpixel.rgba = "rgb";

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

  services.logind.powerKey = "suspend"; # defaults to `poweroff`

  services.fwupd.enable = true;

  # TODO: not have ssh as part of base? don't want ssh exposed on this machin
  services.openssh.enable = lib.mkForce false;

  # bluetooth waow
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  # also smartcards (???)
  services.pcscd.enable = true;

  system.stateVersion = "23.11";
}
