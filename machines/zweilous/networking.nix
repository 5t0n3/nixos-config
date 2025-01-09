{
  # networkmanager too
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  # gotta be able to manage it
  users.users.stone.extraGroups = ["networkmanager"];

  # tailscaleeee
  services.tailscale.enable = true;

  # exposing to local network or smth
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 8000;
      to = 8010;
    }
  ];

  # wireguard?
  networking.firewall.allowedUDPPorts = [58666 58667];
}
