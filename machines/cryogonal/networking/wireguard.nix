{config, ...}: {
  # networking.wireguard.enable = true;

  # Allow wireguard UDP traffic through dedicated ports
  # networking.firewall.allowedUDPPorts = [51822 51823];

  age.secrets.wg-privatekey = {
    file = ../secrets/wg-privkey.age;
    owner = "systemd-network";
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.0.0.9/32"];
      dns = ["192.168.1.242"];
      privateKeyFile = config.age.secrets.wg-privatekey.path;

      peers = [
        {
          publicKey = "RHgmEgSpcSA1daZKGeY48UD66c5zESTrvEAe8k9ahxQ=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "50.39.160.194:51821";
          persistentKeepalive = 25;
        }
      ];
    };

    wg1 = {
      address = ["10.100.1.53/32"];
      dns = ["1.1.1.1"];
      # autostart = false;
      privateKeyFile = "/etc/sec.key";

      peers = [
        {
          publicKey = "3AXD9MkrL03Tssx2K9tCiLGadHMGDhM3Z/hd1uYkcSQ=";
          allowedIPs = ["10.100.0.0/16"];
          endpoint = "100.21.91.50:13338";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
