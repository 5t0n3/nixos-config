{
  environment.etc = {
    "fail2ban/action.d/iptables-forward.local".source = ./iptables-forward.local;

    "fail2ban/filter.d/vaultwarden.local".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      failregex = Username or password is incorrect\\. Try again\\. IP: <ADDR>\\. Username:
                  Invalid admin token\\. IP: <ADDR>$
                  Invalid TOTP code! Server time: .* IP: <ADDR>$
      ignoreregex =
    '';
  };

  services.fail2ban = {
    enable = true;
    banaction-allports = "iptables-forward[type=allports]";
    jails.vaultwarden = ''
      enabled = true
      port = 8016
      backend = systemd
      filter = vaultwarden[journalmatch='_SYSTEMD_UNIT=vaultwarden.service']
      banaction = %(banaction_allports)s
      maxretry = 3
      bantime = 14400
      findtime = 14400
    '';
  };
}
