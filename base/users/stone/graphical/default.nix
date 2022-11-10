{ config, pkgs, lib, nixosConfig, ... }:

with lib;
let
  cfg = config.stone.graphical;
  graphicalType = nixosConfig.stone.graphical.type;
in {
  options.stone.graphical.enable = mkOption {
    description =
      "Whether to enable a graphical user environment & common programs.";
    default = nixosConfig.stone.graphical.enable;
    example = true;
    type = types.bool;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # TODO: betterdiscord plugins/themes?
      home.packages = with pkgs; [
        # internet
        discord
        betterdiscordctl
        firefox

        # command line utilities
        brightnessctl
        scrot
        xclip
        xorg.xmodmap

        # themes
        nordic
        zafiro-icons
        capitaine-cursors

        # other stuff?
        alacritty
        libreoffice
        # (retroarch.override { cores = [ libretro.mgba ]; })
      ];

      xdg.configFile."alacritty/alacritty.yml".source = ./alacritty.yml;

      services.dunst.enable = true;
    }
    (mkIf (graphicalType == "x") {
      programs.feh.enable = true;

      programs.rofi = {
        enable = true;
        theme = "purple";
      };

      xsession.enable = true;

      # TODO: bring xmonad config into here (?)
      xsession.windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: [ haskellPackages.xmobar ];
      };

      programs.xmobar.enable = true;
      xdg.configFile."xmobar/xmobarrc".source = ./xmobarrc;

      services.xscreensaver.enable = true;
    })
  ]);
}
