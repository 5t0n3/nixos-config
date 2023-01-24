{modulesPath, ...}: {
  imports = ["${modulesPath}/profiles/minimal.nix"];

  wsl = {
    enable = true;
    defaultUser = "stone";
    nativeSystemd = true;
    wslConf.network.generateResolvConf = false;
  };

  networking.hostName = "spiritomb";
  networking.nameservers = ["192.168.1.242" "1.1.1.1"];

  system.stateVersion = "22.05";
}
