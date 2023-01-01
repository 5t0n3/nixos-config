{modulesPath, ...}: {
  imports = ["${modulesPath}/profiles/minimal.nix"];

  wsl = {
    enable = true;
    defaultUser = "stone";
    startMenuLaunchers = true;
    wslConf.network = {
      hostname = "spiritomb";
      generateResolvConf = false;
    };
  };

  networking.hostName = "spiritomb";
  networking.nameservers = ["192.168.1.242" "1.1.1.1"];

  environment.noXlibs = false;

  system.stateVersion = "22.05";
}
