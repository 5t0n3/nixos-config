{
  imports = [ ./networkd.nix ./wireguard.nix ];
  stone.wireless = {
    enable = true;
    interfaces = [ "wlp3s0" ];
  };
}
