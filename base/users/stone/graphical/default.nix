{ config, pkgs, lib, nixosConfig, inputs, ... }:

with lib;
let
  cfg = config.stone.graphical;
  graphicalType = nixosConfig.stone.graphical.type;
in {
  imports = [ inputs.hyprland.homeManagerModules.default ];

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

        # command line utilities
        brightnessctl

        # themes
        nordic
        zafiro-icons
        capitaine-cursors

        # productivity?
        libreoffice
        nextcloud-client
        obsidian

        # other stuff?
        alacritty
        cider
        ghidra
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

      # Screenshotting/clipboard utilities
      home.packages = with pkgs; [ scrot xclip firefox ];

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

    (mkIf (graphicalType == "wayland") {
      # complains about seatd socket not existing?
      wayland.windowManager.hyprland = {
        enable = true;

        # Allow for tweaking config on the fly
        extraConfig = ''
          source = ~/.config/hypr/hyprland-extra.conf
        '';
      };

      home.packages = with pkgs; [
        hyprpaper
        swaylock
        waybar
        wofi
        firefox-wayland
      ];
    })
  ]);
}
