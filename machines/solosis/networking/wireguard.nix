{ config, ... }:

{
  networking.wireguard.enable = true;

  # Allow wireguard UDP traffic through dedicated port
  networking.firewall.allowedUDPPorts = [ 51822 ];

  age.secrets.wg-privatekey.file = ../secrets/wg-solosis.age;

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
            AllowedIPs = [ "0.0.0.0/0" ];
            Endpoint = "50.45.159.39:51821";
            PersistentKeepalive = 25;
          };
        }];
      };
    };

    # TODO: learn more about the prefix numbers :)
    networks."10-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.0.0.3/32" ];
      # TODO: figure out whether I need to add this
      dns = [ "10.0.0.1" ];
    };
  };
}
