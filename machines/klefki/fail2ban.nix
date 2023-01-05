{lib, ...}: let
  mkJail = name: failregex: {
    environment.etc."fail2ban-filter-${name}" = {
      target = "fail2ban/filter.d/${name}.local";
      text = ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex = ${failregex}
        ignoreregex =
      '';
    };

    services.fail2ban.jails.${name} = ''
      enabled = true
      port = 8016
      backend = systemd
      filter = ${name}[journalmatch='_SYSTEMD_UNIT=vaultwarden.service']
      banaction = %(banaction_allports)s
      maxretry = 3
      bantime = 14400
      findtime = 14400
    '';
  };
in
  lib.mkMerge ([
      {
        services.fail2ban = {
          enable = true;
          banaction-allports = "iptables[type=allports]";
        };
      }
    ]
    ++ lib.mapAttrsToList mkJail {
      vaultwarden = "Username or password is incorrect\\. Try again\\. IP: <ADDR>\\. Username:";
      vaultwarden-admin = "Invalid admin token. IP: <ADDR>$";
    })
