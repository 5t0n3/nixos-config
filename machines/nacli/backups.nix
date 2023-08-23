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
    requires = ["vaultwarden-backup.service"];
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

    after = ["network-online.target"];

    serviceConfig = {
      User = "vaultwarden";
      WorkingDirectory = "/var/lib/bitwarden_rs";
      PrivateTmp = true;
      LoadCredential = "config.json:/var/lib/bitwarden_rs/backup-config.json";
      ExecStart = "${backup-python}/bin/python3 ${./vw_backup.py}";
    };
  };
}
