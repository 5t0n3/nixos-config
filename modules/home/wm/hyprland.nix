{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.stone.wm.hyprland;
  hyprpaper = inputs.hyprpaper.packages.${pkgs.system}.hyprpaper;
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

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

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      settings =
        lib.recursiveUpdate {
          exec-once = [
            "waybar &"
          ];

          input = {
            kb_layout = "us";
            kb_options = "caps:swapescape";
            numlock_by_default = true;
            follow_mouse = 2; # TODO: test
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

          gestures.workspace_swipe = true;

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

              # launching programs
              "$mainMod SHIFT, Return, exec, kitty"
              "$mainMod, C, killactive,"
              "$mainMod, M, exit,"
              "$mainMod, E, exec, dolphin"
              "$mainMod, V, togglefloating,"
              "$mainMod, R, exec, wofi --show drun"
              "$mainMod, U, togglesplit,"

              # brightness
              ",XF86MonBrightnessUp, exec, brightnessctl set +10%"
              ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"

              # Move focus with mainMod + HJKL (vim ftw)
              "$mainMod, H, movefocus, l"
              "$mainMod, L, movefocus, r"
              "$mainMod, K, movefocus, u"
              "$mainMod, J, movefocus, d"

              # swap windows with mainMod + shift + HJKL
              "$mainMod SHIFT, H, swapwindow, l"
              "$mainMod SHIFT, J, swapwindow, d"
              "$mainMod SHIFT, K, swapwindow, u"
              "$mainMod SHIFT, L, swapwindow, r"

              # scroll between open workspaces
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up, workspace, e-1"

              # trying out a special workspace?
              "$mainMod SHIFT, X, movetoworkspace, special"
              "$mainMod, S, togglespecialworkspace,"
            ]
            ++ (lib.concatMap (n: let
              nStr = toString n;
            in [
              # moving windows/focus between workspaces
              "$mainMod, ${nStr}, workspace, ${nStr}"
              "$mainMod SHIFT, ${nStr}, movetoworkspace, ${nStr}"
            ]) (lib.range 1 10));

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

    # hyprpaper for wallpaper :)
    home.packages = [hyprpaper pkgs.swaylock-effects];

    # swayidle config
    # TODO: placement
    services.swayidle = let
      swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
      hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
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
  };
}
