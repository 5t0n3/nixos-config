{ config, pkgs, lib, nixosConfig, ... }:

with lib;
let enabled = config.stone.graphical;
in {
  options.stone.graphical = mkOption {
    description =
      "Whether to enable a graphical user environment & common programs.";
    default = nixosConfig.stone.graphical;
    example = true;
    type = types.bool;
  };

  config = mkIf enabled {
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

    programs.feh.enable = true;

    programs.rofi = {
      enable = true;
      theme = "purple";
    };

    # TODO: bring xmonad config into here (?)
    xsession.windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [ haskellPackages.xmobar ];
    };

    programs.xmobar.enable = true;
    xdg.configFile."xmobar/xmobarrc".source = ./xmobarrc;

    services.xscreensaver.enable = true;
    services.dunst.enable = true;
  };
}
