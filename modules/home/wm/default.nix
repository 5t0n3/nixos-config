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
    programs.kitty.enable = true;
    programs.wofi.enable = true;
    programs.waybar.enable = true;
    services.dunst.enable = true;

    # TODO: profile config with arkenfox user.js?
    programs.firefox.enable = true;

    # TODO: placement
    services.gnome-keyring.enable = true;

    home.packages =
      lib.attrVals [
        "oculante" # image viewer
        "dolphin" # file browser
        "pavucontrol" # volume control
        "wl-clipboard" # clipboard management

        # screenshots
        "grim"
        "slurp"
      ]
      pkgs;

    # GTK & cursor theming
    gtk = {
      enable = true;
      theme = {
        package = pkgs.nordic;
        name = "Nordic";
      };
      iconTheme = {
        # TODO: just use adwaita or something? this one seems to be missing some stuff
        package = pkgs.zafiro-icons;
        name = "Zafiro-icons";
      };
    };

    home.pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      gtk.enable = true;
    };
  };
}
