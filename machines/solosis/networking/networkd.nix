{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.useDHCP = true;

  # Enable & configure systemd-networkd
  systemd.network = {
    enable = true;
    networks = {
      "40-en-dhcp" = {
        matchConfig.Name = "en*";
        networkConfig.DHCP = "ipv4";
      };
      "45-wl-dhcp" = {
        matchConfig.Name = "wl*";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config.RouteMetric = 1025;
      };
    };
  };

  # Force use of networkd
  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  systemd.network.wait-online.anyInterface = true;
}
