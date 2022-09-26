{ config, lib, ... }:
with lib;
let cfg = config.stone.wireless;
in {
  options.stone.wireless = {
    enable = mkEnableOption "wireless networking";
    interfaces = mkOption {
      type = with types; listOf str;
      example = "wlp3s0";
      description = "The wireless interface(s) to have configured.";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.wifi-psks.file = ../secrets/wifi-psks.age;

    networking.wireless = {
      enable = true;
      userControlled.enable = true;
      interfaces = cfg.interfaces;

      environmentFile = config.age.secrets.wifi-psks.path;
      networks = {
        Cygnus = {
          authProtocols = [ "WPA-PSK" ];
          pskRaw = "@CYGNUS_PSK@";
        };
        eduroam = {
          authProtocols = [ "WPA-EAP" ];
          auth = ''
            eap=PEAP
            phase2="auth=MSCHAPV2"
            identity="@EDUROAM_EMAIL@"
            password="@EDUROAM_PASS@"
          '';
        };
      };
    };
  };
}
