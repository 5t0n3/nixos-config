{config, ...}: {
  networking.wireguard.enable = true;

  # Allow wireguard UDP traffic through dedicated ports
  networking.firewall.allowedUDPPorts = [51822 51823];

  age.secrets.wg-privatekey = {
    file = ../secrets/wg-privkey.age;
    owner = "systemd-network";
  };

  systemd.network = {
    # TODO: figure out if these can be consolidated
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

      "10-wg1" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg1";
          Description = "SEC infra access";
        };

        wireguardConfig = {
          PrivateKeyFile = "/etc/sec.key";
          ListenPort = 51823;
        };

        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "3AXD9MkrL03Tssx2K9tCiLGadHMGDhM3Z/hd1uYkcSQ=";
              AllowedIPs = ["10.100.0.0/16"];
              Endpoint = "100.21.91.50:13338";
              PersistentKeepalive = 25;
            };
          }
        ];
      };
    };

    networks = {
      "10-wg0" = {
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
              Destination = "192.168.1.0/24";
            };
          }
        ];
      };

      "10-wg1" = {
        name = "wg1";
        address = ["10.100.1.53/32"];
        dns = ["1.1.1.1"];

        routes = [
          {
            routeConfig = {
              Gateway = "10.100.0.1";
              GatewayOnLink = true;
              Destination = "10.100.0.0/16";
            };
          }
        ];
      };
    };
  };
}
