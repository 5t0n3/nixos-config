{ config, pkgs, lib, ... }:

{
  # Global useDHCP flag is deprecated
  networking.useDHCP = false;

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
  systemd.services.systemd-networkd-wait-online = {
    description = "Wait for any network interface to be configured";
    conflicts = [ "shutdown.target" ];
    requisite = [ "systemd-networkd.service" ];
    after = [ "systemd-networkd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
      ];
    };
  };
  systemd.services."systemd-network-wait-online@".enable = false;
}
