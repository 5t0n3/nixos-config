{
  pkgs,
  lib,
  ...
}: let
  backup-python = pkgs.python3.withPackages (lib.attrVals ["cryptography" "b2sdk" "setuptools"]);
in {
  systemd.services."vaultwarden-backup" = {
    enable = true;
    description = "Vaultwarden backup to Backblaze B2";

    wants = ["network-online.target"];
    after = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${backup-python}/bin/python ${./vw_backup.py}";
      User = "vaultwarden";
      WorkingDirectory = "/var/lib/bitwarden_rs";
      PrivateTmp = true;
      LoadCredential = "config.json:/var/lib/bitwarden_rs/backup-config.json";
    };
  };

  systemd.timers."vaultwarden-backup" = {
    enable = true;
    description = "Timer to trigger daily backup of Vaultwarden data";

    wantedBy = ["timers.target"];

    timerConfig = {
      Persistent = true;
      OnCalendar = "daily";
      Unit = "vaultwarden-backup.service";
    };
  };
}
