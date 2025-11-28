{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  cfg = config.stone.wm.hyprland;
  hyprpaper = inputs.hyprpaper.packages.${system}.hyprpaper;
in {
  options = {
    stone.wm.hyprland = {
      enable = lib.mkEnableOption "Hyprland & a slew of other basic graphical programs";
      extraSettings = lib.mkOption {
        default = {};
        # borrowed from https://github.com/nix-community/home-manager/blob/7b3fca5adcf6c709874a8f2e0c364fe9c58db989/modules/services/window-managers/hyprland.nix#L114-L127
        type = with lib.types; let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "Hyprland configuration value";
            };
        in
          valueType;
        description = "Extra Hyprland settings to add to its config.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: bring waybar config into here/wm section (or separate out)
    # TODO: eww?

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      # settings = let
      # TODO: better swaylock stuffs
      # swaylock-effects = pkgs.swaylock-effects;
      # lock-screenshot = "${swaylock-effects} --clock -S --effect-pixelate 10 --effect-vignette 0.5:0.5 --indicator --indicator-radius 200 --indicator-thickness 20 --inside-color 2e3440 --inside-wrong-color 3cc48b --ring-wrong-color=32996e --text-ver hmmm... --text-wrong cringe";
      # lock-bsod = "${swaylock-effects} -i ~/Pictures/bsod.png";
      # in
      settings =
        lib.recursiveUpdate {
          # dynamic monitor setup attempt
          source = [
            "~/.config/hypr/conf.d/*"
          ];

          monitor = [
            ", preferred, auto-left, 1"
          ];

          exec-once = [
            "waybar &"
            "hyprpaper &"
          ];

          input = {
            kb_layout = "us";
            kb_variant = "altgr-intl";
            kb_options = "caps:swapescape";
            numlock_by_default = true;
            follow_mouse = 2;
            touchpad.natural_scroll = true;
          };

          general = {
            gaps_in = 3;
            gaps_out = 7;
            border_size = 2;
            "col.active_border" = "rgba(1affffee)";
            "col.inactive_border" = "rgba(595959aa)";
            layout = "dwindle";
          };

          misc = {
            disable_hyprland_logo = true;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
            new_window_takes_over_fullscreen = 1;
          };

          # oo round windows
          decoration.rounding = 10;

          # TODO: tune this or something
          bezier = "myBezier, 0.02, 0.9, 0.05, 1";

          animations = {
            enabled = true;

            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };

          dwindle.smart_split = true;

          # breaking change in hyprland 0.51.0
          gesture = [
            "3, horizontal, workspace"
          ];

          # TODO: find a better place for this
          windowrulev2 = [
            "float, class:^(ghidra-Ghidra)$"
            "tile, class:^(ghidra-Ghidra)$, title:^(CodeBrowser)"
            "tile, class:^(ghidra-Ghidra)$, title:^(Ghidra: )"
          ];

          "$mainMod" = "SUPER";

          bind =
            [
              # locking/shutdown
              "$mainMod CONTROL_L, L, exec, swaylock -fF -c 2e3440"
              "$mainMod CONTROL_L, B, exec, systemctl poweroff"

              # Screenshots :)
              "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy -t image/png"
              "$mainMod CONTROL_L, S, exec, grim -g \"$(slurp)\" \"/tmp/$(date +\"%Y-%m-%d-%H:%M:%S\").png\""

              # launching/yeeting stuff
              "$mainMod SHIFT, Return, exec, wezterm"
              "$mainMod, C, killactive,"
              "$mainMod, M, exit,"
              "$mainMod, V, togglefloating,"
              "$mainMod, R, exec, wofi --show drun"
              "$mainMod, U, togglesplit,"

              # brightness
              ",XF86MonBrightnessUp, exec, brightnessctl set +10%"
              ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"

              # Move focus with mainMod + HJKL
              "$mainMod, H, movefocus, l"
              "$mainMod, L, movefocus, r"
              "$mainMod, K, movefocus, u"
              "$mainMod, J, movefocus, d"

              # swap windows with mainMod + shift + HJKL
              "$mainMod SHIFT, H, swapwindow, l"
              "$mainMod SHIFT, J, swapwindow, d"
              "$mainMod SHIFT, K, swapwindow, u"
              "$mainMod SHIFT, L, swapwindow, r"

              # special workspace
              "$mainMod SHIFT, X, movetoworkspace, special"
              "$mainMod, S, togglespecialworkspace,"

              # toggle window fullscreen (0 -> cover status bar)
              "$mainMod SHIFT, F, fullscreen, 0, toggle"
              "$mainMod, N, cyclenext"

              # grouping
              "$mainMod, G, togglegroup"
              "$mainMod SHIFT, I, moveintogroup, u"
              "$mainMod SHIFT, G, moveoutofgroup"
              "$mainMod SHIFT, N, changegroupactive, f"

              # workspace 10 -> key 0 (doesn't quite fit in below chunk)
              "$mainMod, 0, workspace, 10"
              "$mainMod SHIFT, 0, movetoworkspace, 10"
            ]
            ++ (lib.concatMap (n: let
              nStr = toString n;
            in [
              # moving windows/focus between workspaces
              "$mainMod, ${nStr}, workspace, ${nStr}"
              "$mainMod SHIFT, ${nStr}, movetoworkspace, ${nStr}"
            ]) (lib.range 1 9));

          # window movement & resizing
          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        }
        cfg.extraSettings;
    };

    # auto-start hyprland if logging in from tty1
    programs.fish.loginShellInit = ''
      if test (tty) = "/dev/tty1"
        exec Hyprland &> /dev/null
      end
    '';

    # hyprpaper for wallpaper :) (+ swaylock effects for locking)
    home.packages = [hyprpaper pkgs.swaylock-effects];

    # swayidle config
    # TODO: placement
    services.swayidle = let
      swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
      systemctl = "${pkgs.systemd}/bin/systemctl";
    in {
      enable = true;
      # TODO: figure these out
      timeouts = [
        {
          # lock after 3 minutes
          timeout = 180;
          command = "${swaylock} -fF -c 2e3440";
        }
        {
          # turn off after 30 minutes
          timeout = 1800;
          command = "${systemctl} poweroff";
        }
      ];
    };
  };
}
