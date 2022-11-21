{
  config,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix ./networking ./backups.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs" "ntfs"];

  networking.hostName = "solosis";

  # Put /tmp on a tmpfs
  boot.cleanTmpDir = false;
  boot.tmpOnTmpfs = true;

  # Other ZFS settings
  networking.hostId = "a4513dad";
  services.zfs = {
    trim.enable = true;
    autoSnapshot.enable = true;
    autoScrub.enable = true;
  };

  # Mount Windows partition
  fileSystems."/mnt/windows" = {
    device = "/dev/nvme0n1p3";
    fsType = "ntfs";
    options = ["rw" "uid=1000"];
  };

  # enable microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # SERVICES

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Backups
  age.secrets.rsyncd-secrets.file = ./secrets/rsync-secrets.age;
  stone.backups = {
    enable = true;
    hosts = ["192.168.1.174"];
    shares = {
      stoneHome = {
        path = "/home/stone";
        comment = "The home directory of user stone.";
      };
    };
    secretsFile = config.age.secrets.rsyncd-secrets.path;
  };

  stone.graphical.enable = true;

  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = ["wheel"];
        noPass = false;
        keepEnv = true;
      }
    ];
  };

  system.stateVersion = "20.09";
}
