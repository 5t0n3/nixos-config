{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.0.0.9/32"];
      dns = ["192.168.1.242"];
      privateKeyFile = "/etc/wg.key";

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
      privateKeyFile = "/etc/sec.key";

      peers = [
        {
          publicKey = "3AXD9MkrL03Tssx2K9tCiLGadHMGDhM3Z/hd1uYkcSQ=";
          allowedIPs = ["10.100.1.0/24"];
          endpoint = "100.21.91.50:13338";
          persistentKeepalive = 25;
        }
      ];
    };

    wg2 = {
      address = ["10.100.2.50/32"];
      dns = ["1.1.1.1"];
      privateKeyFile = "/etc/cdc.key";

      peers = [
        {
          publicKey = "jIeRyIFz2yS/3lrn47IobKp5+DbWRpfYG+MfgRoKvWs=";
          allowedIPs = ["10.100.2.0/24" "10.15.0.0/24"];
          endpoint = "100.21.91.50:13335";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
