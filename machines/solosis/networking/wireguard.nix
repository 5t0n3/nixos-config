{ config, ... }:

{
  networking.wireguard.enable = true;

  # Allow wireguard UDP traffic through dedicated port
  networking.firewall.allowedUDPPorts = [ 51822 ];

  age.secrets.wg-privatekey = {
    file = ../secrets/wg-solosis.age;
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

        wireguardPeers = [{
          wireguardPeerConfig = {
            PublicKey = "RHgmEgSpcSA1daZKGeY48UD66c5zESTrvEAe8k9ahxQ=";
            AllowedIPs = [ "0.0.0.0/0" "192.168.1.1/24" ];
            Endpoint = "othman.io:51821";
            PersistentKeepalive = 25;
          };
        }];
      };
    };

    networks."10-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.0.0.3/32" ];
      dns = [ "192.168.1.242" ];
    };
  };
}
