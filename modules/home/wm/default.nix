{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.stone.wm;
in {
  imports = [
    ./hyprland.nix
  ];

  options = {
    stone.wm.enable = lib.mkEnableOption "a window manager & some basic companion programs";
  };

  config = lib.mkIf cfg.enable {
    # default to hyprland (only option for now)
    stone.wm.hyprland.enable = lib.mkDefault true;

    # base programs
    programs.wofi.enable = true;
    programs.waybar.enable = true;
    services.dunst.enable = true;

    # kitty config cause home-manager is mean :(
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 13;
      };

      keybindings = {
        "kitty_mod+enter" = "launch --cwd=current";
        "kitty_mod+n" = "new_os_window_with_cwd";
      };

      settings = {
        enable_audio_bell = false;
        close_on_child_death = true;

        # nordic color scheme
        # inspired by:
        # - https://gist.github.com/marcusramberg/64010234c95a93d953e8c79fdaf94192
        # - https://github.com/arcticicestudio/nord-hyper
        foreground = "#D8DEE9";
        background = "#2E3440";
        selection_foreground = "#000000";
        selection_background = "#FFFACD";
        url_color = "#0087BD";
        cursor = "#81A1C1";

        # black
        color0 = "#3B4252";
        color8 = "#4C566A";

        # red
        color1 = "#BF616A";
        color9 = "#BF616A";

        # green
        color2 = "#A3BE8C";
        color10 = "#A3BE8C";

        # yellow
        color3 = "#EBCB8B";
        color11 = "#EBCB8B";

        # blue
        color4 = "#81A1C1";
        color12 = "#81A1C1";

        # magenta
        color5 = "#B48EAD";
        color13 = "#B48EAD";

        # cyan
        color6 = "#88C0D0";
        color14 = "#8FBCBB";

        # white
        color7 = "#E5E9F0";
        color15 = "#ECEFF4";
      };
    };

    # TODO: profile config with arkenfox user.js?
    programs.firefox.enable = true;

    home.packages =
      lib.attrVals [
        "oculante" # image viewer
        "dolphin" # file browser
        "pavucontrol" # volume control
        "wl-clipboard" # clipboard management
        "xdg-utils" # mostly for xdg-open
        "brightnessctl" # for brightness

        # screenshots
        "grim"
        "slurp"

        # trying it out
        "wezterm"
      ]
      pkgs;

    # cursor theming
    home.pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      gtk.enable = true;
    };
  };
}
