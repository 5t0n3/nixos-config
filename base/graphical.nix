{ config, pkgs, lib, ... }:

with lib;
let cfg = config.stone.graphical;
in {
  options.stone.graphical =
    mkEnableOption "X server and various common programs";

  config = mkIf cfg {
    services.xserver = {
      enable = true;
      layout = "us";

      # LightDM display manager
      displayManager.lightdm = {
        enable = true;

        greeters.mini = {
          enable = true;
          user = "stone";
          extraConfig = ''
                      [greeter]
                      show-password-label = false
                      password-alignment = left

                      [greeter-theme]
            	        font-size = 2rem
                      text-color = #eceff4
                      window-color = #88c0d0
                      border-color = #0d1327
                      background-color = #2e3440
                      background-image = ""
          '';
        };
      };

      # hack to manage window manager through home-manager (?)
      desktopManager.xterm.enable = true;

      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
      };
    };

    fonts.fonts = with pkgs;
      [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
  };
}
