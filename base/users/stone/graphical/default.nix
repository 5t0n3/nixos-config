{ config, pkgs, lib, nixosConfig, inputs, ... }:

with lib;
let
  cfg = config.stone.graphical;
  graphicalType = nixosConfig.stone.graphical.type;

  # This probably doesn't work in all cases but eh
  waylandElectron = pname:
    pkgs.symlinkJoin {
      name = pname;
      paths = [ pkgs.${pname} ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${pname} \
          --add-flags "--enable-features=UseOzonePlatform" \
          --add-flags "--ozone-platform=wayland"
      '';
    };
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

        # productivity
        libreoffice
        nextcloud-client

        # other stuff?
        alacritty
        ghidra
        # (retroarch.override { cores = [ libretro.mgba ]; })
      ];

      programs.emacs = {
        enable = true;
        package = pkgs.emacsPgtkNativeComp;
      };

      xdg.configFile."alacritty/alacritty.yml".source = ./alacritty.yml;

      services.dunst.enable = true;
    }

    (mkIf (graphicalType == "x") {
      programs.feh.enable = true;

      programs.rofi = {
        enable = true;
        theme = "purple";
      };

      home.packages = with pkgs; [ scrot xclip firefox obsidian cider ];

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
      # complains about seatd socket not existing/EGL context?
      # wayland.windowManager.hyprland = {
      # enable = true;

      # Allow for tweaking config on the fly
      # extraConfig = ''
      #   source = ~/.config/hypr/hyprland-extra.conf
      # '';
      # };

      home.packages = with pkgs;
        [
          # utilities :)
          hyprpaper
          swaylock
          waybar
          wofi
          wl-clipboard

          # actual apps
          firefox-wayland
        ] ++ map waylandElectron [ "obsidian" "cider" ];
    })
  ]);
}
