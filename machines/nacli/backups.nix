{
  pkgs,
  lib,
  ...
}: let
  backup-python = pkgs.python3.withPackages (lib.attrVals ["cryptography" "b2sdk" "setuptools"]);
in {
  systemd.timers."vaultwarden-backup" = {
    enable = true;
    description = "Timer to trigger daily backup of Vaultwarden data";

    after = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    timerConfig = {
      Persistent = true;
      OnCalendar = "daily";
      Unit = "vaultarden-backup.service";
    };
  };

  systemd.services."vaultwarden-backup" = {
    enable = true;
    description = "Vaultwarden backup to Backblaze B2";

    after = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      User = "vaultwarden";
      WorkingDirectory = "/var/lib/bitwarden_rs";
      PrivateTmp = true;
      LoadCredential = "config.json:/var/lib/bitwarden_rs/backup-config.json";
      ExecStart = "${backup-python}/bin/python ${./vw_backup.py}";
    };
  };
}
