{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.stone.graphical;
in {
  options.stone.graphical = {
    enable = mkEnableOption "graphical programs/config";
    type = mkOption {
      type = types.enum ["x" "wayland"];
      default = "x";
      example = "wayland";
      description = "Which display server to run";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.type == "x") {
      services.xserver = {
        enable = true;
        layout = "us";

        # hack for home-manager managed window manager (?)
        displayManager.session = [
          {
            manage = "desktop";
            name = "xsession";
            start = ''
              ${pkgs.runtimeShell} $HOME/.xsession &
              waitPID=$!
            '';
          }
        ];
        displayManager.defaultSession = "xsession";

        # LightDM display manager
        displayManager.lightdm = {
          enable = true;

          greeters.mini = {
            enable = true;
            user = "stone";
            extraConfig = ''
               [greeter]
               show-password-label = false
               password-alignment = left

               [greeter-theme]
              font-size = 1rem
               text-color = #eceff4
               window-color = #88c0d0
               border-color = #0d1327
               background-color = #2e3440
               background-image = ""
            '';
          };
        };

        libinput = {
          enable = true;
          touchpad.naturalScrolling = true;
        };
      };

      # sound-related stuff
      sound.enable = true;
      hardware.pulseaudio.enable = true;
    })

    (mkIf (cfg.type == "wayland") {
      # TODO: get working inside home-manager
      programs.hyprland.enable = true;

      # hack to make gtk startup not take forever?? (nixpkgs issue #156830)
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };

      # Needed for hyprland portal
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      # Swaylock needs this for authentication (?)
      security.pam.services.swaylock = {};

      nixpkgs.overlays = [inputs.hyprpaper.overlays.default];

      # add relevant cachix servers
      nix.settings = {
        substituters = [
          "https://nixpkgs-wayland.cachix.org"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
    })

    {
      fonts.enableDefaultFonts = true;
      fonts.fonts = with pkgs; [(nerdfonts.override {fonts = ["JetBrainsMono"];})];

      nixpkgs.overlays = [inputs.emacs-overlay.overlays.emacs];
    }
  ]);
}
