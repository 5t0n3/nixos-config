{
  config,
  pkgs,
  lib,
  nixosConfig,
  inputs,
  ...
}:
with lib; let
  cfg = config.stone.graphical;
  graphicalType = nixosConfig.stone.graphical.type;

  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
  hyprpaper = inputs.hyprpaper.packages.${pkgs.system}.hyprpaper;
  waybar-hyprland = pkgs.waybar.override {hyprlandSupport = true;};
in {
  options.stone.graphical.enable = mkOption {
    description = "Whether to enable a graphical user environment & common programs.";
    default = nixosConfig.stone.graphical.enable;
    example = true;
    type = types.bool;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        # internet
        firefox
        vesktop
        # cinny-desktop

        # command line utilities
        brightnessctl

        # productivity
        unstablePkgs.typst
        libreoffice
        nextcloud-client
        logseq
        pandoc
        reveal-md

        # sound
        pavucontrol
        cider

        # ctf stuffs
        unstablePkgs.ghidra
        # (sage.override {requireSageTests = false;})
        binutils # for `strings` mostly
        file
        hexyl

        # fix missing icons maybe?
        gnome.adwaita-icon-theme

        # we do a little gaming
        prismlauncher

        # other stuff?
        kitty
        xdg-utils
        nil
        alejandra
        veracrypt
      ];

      # nheko ig?
      programs.nheko.enable = true;

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      gtk = {
        enable = true;
        theme = {
          package = pkgs.nordic;
          name = "Nordic";
        };
        iconTheme = {
          package = pkgs.zafiro-icons;
          name = "Zafiro-icons";
        };
      };

      home.pointerCursor = {
        package = pkgs.capitaine-cursors;
        name = "capitaine-cursors";
        x11.enable = true;
        gtk.enable = true;
      };

      services.dunst.enable = true;
    }

    (mkIf (graphicalType == "x") {
      programs.feh.enable = true;

      programs.rofi = {
        enable = true;
        theme = "purple";
      };

      home.packages = with pkgs; [scrot xclip cider];

      xsession.enable = true;

      # TODO: bring xmonad config into here (?)
      xsession.windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: [haskellPackages.xmobar];
      };

      programs.xmobar.enable = true;
      xdg.configFile."xmobar/xmobarrc".source = ./xmobarrc;

      services.xscreensaver.enable = true;
    })

    (mkIf (graphicalType == "wayland") {
      home.packages = builtins.attrValues {
        inherit hyprpaper waybar-hyprland;
        inherit (pkgs) swaylock-effects wofi wl-clipboard grim slurp imv oculante;
      };

      services.swayidle = let
        swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
        hyprctl = "${pkgs.hyprland}/bin/hyprctl";
        systemctl = "${pkgs.systemd}/bin/systemctl";
      in {
        enable = true;
        package = pkgs.swayidle;
        # TODO: check if this actually works?
        systemdTarget = "graphical-session.target";
        timeouts = [
          {
            # lock after 3 minutes
            timeout = 180;
            command = "${swaylock} -fF -c 2e3440";
          }
          {
            # turn screen(s) off after 10 minutes
            timeout = 600;
            command = "${hyprctl} dispatch dpms off";
            resumeCommand = "${hyprctl} dispatch dpms on";
          }
          {
            # turn off after 30 minutes
            timeout = 1800;
            command = "${systemctl} poweroff";
          }
        ];
      };

      # taken from https://git.sr.ht/~misterio/nix-config/tree/main/item/home/misterio/features/desktop/hyprland/default.nix#L9-13
      # auto-start hyprland if logging in from tty1
      programs.fish.loginShellInit = ''
        if test (tty) = "/dev/tty1"
          exec Hyprland &> /dev/null
        end
      '';

      services.dunst.package = pkgs.dunst;
    })
  ]);
}
