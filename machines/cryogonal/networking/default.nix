{ pkgs, ... }:

{
  imports = [./wireguard.nix];

  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  systemd.network = {
    enable = true;
    networks = {
      "40-en-dhcp" = {
        name = "en*";
        networkConfig.DHCP = "ipv4";
      };
      "45-wl-dhcp" = {
        name = "wl*";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config.RouteMetric = 1025;
      };
    };
    wait-online.anyInterface = true;
  };

  # stone.wireless = {
  #   enable = true;
  #   interfaces = ["wlp0s20f3"];
  # };
  
  # try iwd instead?
  networking.wireless.iwd.enable = true;
  environment.systemPackages = [pkgs.iwgtk];

  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.interfaces.enp0s13f0u1u3.useDHCP = true;
}
