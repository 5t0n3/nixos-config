{
  pkgs,
  lib,
  ...
}: let
  backup-python = pkgs.python3.withPackages (lib.attrVals ["cryptography" "b2sdk"]);
in {
  users.users.vaultwarden-backup = {
    isSystemUser = true;
    group = "vaultwarden";
  };

  systemd.timers."vaultwarden-backup" = {
    enable = true;
    description = "Timer to trigger daily backup of vaultwarden data";

    wantedBy = ["timers.target"];

    timerConfig = {
      Persistent = true;
      OnCalendar = "daily";
      Unit = "vaultarden-backup.service";
    };
  };

  systemd.services."vaultwarden-backup" = {
    enable = true;
    description = "Vaultwarden backup to Backblaze B2";

    wants = ["network-online.target"];
    after = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      User = "vaultwarden-backup";
      WorkingDirectory = "/var/lib/bitwarden_rs";
      PrivateTmp = true;
      LoadCredential = "config.json:/var/lib/bitwarden_rs/backup-config.json";
      ExecStart = "${backup-python}/bin/python3 ${./vw_backup.py}";
    };
  };
}
