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

      # zoom :(
      "zoom"
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
      "zotero"
      "zoom-us"
    ]
    pkgs;
  documentation.dev.enable = true;

  # we do a little virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # don't really care about non-x86 architectures
      package = pkgs.qemu_kvm;

      # emulated tpms wowow
      swtpm.enable = true;
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

  services.logind.settings.Login.HandlePowerKey = "suspend"; # defaults to `poweroff`

  services.fwupd.enable = true;

  # TODO: not have ssh as part of base? don't want ssh exposed on this machin
  services.openssh.enable = lib.mkForce false;

  # bluetooth waow
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  # also smartcards (???)
  services.pcscd.enable = true;

  # pain and suffering and kernel panics
  boot.crashDump.enable = true;

  # pain and suffering (2)
  services.tailscale.enable = true;

  i18n.defaultLocale = "es_PR.UTF-8";

  system.stateVersion = "23.11";
}
