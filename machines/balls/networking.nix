{
  networking.hostName = "balls";

  # there's no way it's dns
  # it can't be dns
  # it's always dns
  services.resolved.enable = true;

  # networkmanager too
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  # gotta be able to manage it
  users.users.stone.extraGroups = ["networkmanager"];

  # nftables?
  networking.nftables.enable = true;
}
