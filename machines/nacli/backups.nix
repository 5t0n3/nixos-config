{pkgs, ...}: let
  backupScript = pkgs.writeShellApplication {
    name = "backup-vaultwarden";
    runtimeInputs = builtins.attrValues {
      inherit (pkgs) backblaze-b2 coreutils sqlite;
    };
    text = ''
      # systemd doesn't do environment variable expansion in Environment= options :(
      export B2_ACCOUNT_INFO=$STATE_DIRECTORY/.b2_account_info

      # authorize to backblaze if that hasn't been done already
      if [ ! -f $B2_ACCOUNT_INFO ]; then
        b2 authorize-account
      fi

      # create a separate backup copy of the database
      # TODO: consistent filename for backup purposes? (e.g. .bak)
      DB_BACKUP=$(mktemp)
      sqlite3 db.sqlite3 ".backup $DB_BACKUP"

      # upload stuff to B2
      BACKUP_FILES=$DB_BACKUP attachments rsa_key.pem rsa_key.pub.pem
      for file in $BACKUP_FILES; do
        # TODO: path dependent on file itself?
        b2 sync $file "b2://[bucket]/[path]"
      done
    '';
  };
in {
  users.users.vaultwarden-backup = {
    isSystemUser = true;
    group = "vaultwarden";
  };

  systemd.services."vaultwarden-backup" = {
    enable = true;
    description = "Vaultwarden backup to Backblaze B2";

    wants = ["network-online.target"];
    after = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    path = [backupScript];

    serviceConfig = {
      PrivateTmp = true;
      WorkingDirectory = "/var/lib/bitwarden_rs";
      StateDirectory = "vaultwarden-backup";
      StateDirectoryMode = "0700";

      # TODO: B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY are required
      EnvironmentFile = "TODO";
    };
  };
}
