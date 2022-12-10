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

  # This probably doesn't work in all cases but eh
  waylandElectron = pname:
    pkgs.symlinkJoin {
      name = pname;
      paths = [pkgs.${pname}];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/${pname} \
          --add-flags "--enable-features=UseOzonePlatform" \
          --add-flags "--ozone-platform=wayland"
      '';
    };

  waylandPkgs = inputs.nixpkgs-wayland.packages.${pkgs.system};
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};

  # Taken from hyprland overlay
  waybar-experimental = waylandPkgs.waybar.overrideAttrs (oldAttrs: {
    mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
  });
in {
  # imports = [inputs.hyprland.homeManagerModules.default];

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
        discord
        betterdiscordctl

        # command line utilities
        brightnessctl

        # productivity
        libreoffice
        nextcloud-client

        # sound
        pavucontrol
        cider

        # other stuff?
        alacritty
        ghidra
        # (retroarch.override { cores = [ libretro.mgba ]; })
      ];

      programs.emacs.enable = true;
      services.emacs.enable = true;

      xdg.configFile."alacritty/alacritty.yml".source = ./alacritty.yml;

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
        # TODO: verify if this works on wayland too
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

      programs.emacs.package = pkgs.emacsGit;

      home.packages = with pkgs; [scrot xclip obsidian cider];

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
      # complains about seatd socket not existing/EGL context?
      # wayland.windowManager.hyprland = {
      #   enable = true;

      #   # Allow for tweaking config on the fly
      #   extraConfig = ''
      #     source = ~/.config/hypr/hyprland-extra.conf
      #   '';
      # };

      home.packages =
        builtins.attrValues {
          inherit (pkgs) hyprpaper;
          inherit (waylandPkgs) swaylock wofi wl-clipboard grim slurp imv;
          inherit waybar-experimental;
        }
        ++ map waylandElectron ["obsidian"];

      programs.emacs.package = pkgs.emacsPgtk;
      services.dunst.package = waylandPkgs.dunst;
    })
  ]);
}
