{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.0.0.10/32"];
      privateKeyFile = "/etc/wg.key";

      peers = [
        {
          publicKey = "RHgmEgSpcSA1daZKGeY48UD66c5zESTrvEAe8k9ahxQ=";
          allowedIPs = ["10.0.0.1/24"];
          endpoint = "50.39.160.194:51821";
          presharedKeyFile = "/etc/wg.psk";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
