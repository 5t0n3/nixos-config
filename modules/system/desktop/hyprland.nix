{pkgs, ...}: {
  # hyprland is neat :)
  programs.hyprland.enable = true;

  # hack to make gtk startup not take forever?? (nixpkgs issue #156830)
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # needed for screensharing w/ hyprland
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # stolen from https://nixos.wiki/wiki/PipeWire (also for screensharing)
  security.rtkit.enable = true;

  # swaylock needs this to work
  security.pam.services.swaylock = {};

  # add hyprland cachix server (not that I think I've ever been able to use it)
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
