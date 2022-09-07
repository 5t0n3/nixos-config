{ modulesPath, ... }:

{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  wsl = {
    enable = true;
    defaultUser = "stone";
    startMenuLaunchers = true;
    wslConf.network.hostname = "spiritomb";
  };

  networking.hostName = "spiritomb";

  system.stateVersion = "22.05";
}
