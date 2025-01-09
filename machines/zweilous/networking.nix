{
  # networkmanager too
  networking.networkmanager.enable = true;
  users.users.stone.extraGroups = ["networkmanager"];

  # tailscaleeee
  services.tailscale.enable = true;

  networking.firewall.allowedTCPPortRanges = [
    {
      from = 8000;
      to = 8010;
    }
  ];
}
