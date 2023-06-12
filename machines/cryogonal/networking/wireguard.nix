{config, ...}: {
  networking.wireguard.enable = true;

  # Allow wireguard UDP traffic through dedicated port
  networking.firewall.allowedUDPPorts = [51822];

  age.secrets.wg-privatekey = {
    file = ../secrets/wg-privkey.age;
    owner = "systemd-network";
  };

  systemd.network = {
    netdevs = {
      "10-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          Description = "Wireguard home VPN tunnel";
        };

        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wg-privatekey.path;
          ListenPort = 51822;
        };

        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "RHgmEgSpcSA1daZKGeY48UD66c5zESTrvEAe8k9ahxQ=";
              AllowedIPs = ["0.0.0.0/0" "192.168.1.0/24"];
              Endpoint = "50.39.160.194:51821";
              PersistentKeepalive = 25;
            };
          }
        ];
      };
    };

    networks."10-wg0" = {
      name = "wg0";
      address = ["10.0.0.9/32"];
      dns = ["192.168.1.242"];
      networkConfig = {
        DNSDefaultRoute = true;
        Domains = ["~."];
        # Fails for pi hole local dns entries
        DNSSEC = false;
      };
      routes = [
        {
          routeConfig = {
            Gateway = "10.0.0.1";
            GatewayOnLink = true;
            # Destination = "192.168.1.0/24";
          };
        }
      ];
    };
  };
}
