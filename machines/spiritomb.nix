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

  environment.etc."resolv.conf".text = ''
    nameserver 192.168.1.242
    nameserver 1.1.1.1
  '';

  environment.noXlibs = false;

  networking.hostName = "spiritomb";

  system.stateVersion = "22.05";
}
