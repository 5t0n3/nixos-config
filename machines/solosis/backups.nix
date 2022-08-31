{ config, lib, ... }:

with lib;

let
  cfg = config.stone.backups;
  shareType = {
    options = {
      path = mkOption {
        type = types.str;
        default = "/";
        example = "/home/user";
        description = "The share path to back up.";
      };

      comment = mkOption {
        type = types.str;
        example = "Home directory";
        description = "The comment/description of the share.";
      };
    };
  };
  commonShareAttrs = {
    "strict modes" = false;
    # TODO: Make this an option rather than assuming
    "auth users" = "backuppc";
    "secrets file" = cfg.secretsFile;
    "hosts allow" = concatStringsSep ", " cfg.hosts;
    "read only" = false;
    list = false;
    charset = "utf-8";
  };
in {
  options.stone.backups = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable backups via BackupPC.";
    };

    hosts = mkOption {
      type = with types; listOf str;
      example = [ "192.168.1.2" "192.168.1.10" ];
      description = "The IP of the BackupPC server.";
    };

    shares = mkOption {
      type = with types; attrsOf (submodule shareType);
      description = "The rsync shares to back up via BackupPC.";
    };

    secretsFile = mkOption {
      type = types.str;
      description = "The location of the rsync secrets file.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 873 ];

    services.rsyncd.enable = true;

    services.rsyncd.settings = {
      global = {
        uid = 1000;
        gid = "*";
        "use chroot" = true;
        "max connections" = 2;
        "log file" = "/tmp/rsyncd.log";
      };
    } // mapAttrs (_: value: commonShareAttrs // value) cfg.shares;
  };
}
