{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hyprland.nix
  ];

  # gnome-keyring for secret management
  services.gnome.gnome-keyring.enable = true;

  # nix-index go brr (also why do they default to enabling ugh)
  programs.nix-index.enable = lib.mkForce true;

  # install some fonts (I don't use a lot of these but eh)
  fonts.enableDefaultPackages = true;

  # FIXME: this breaks on non-unstable probably (?) - maybe move to individual systems?
  fonts.packages = [pkgs.noto-fonts-cjk-sans] ++ lib.attrVals ["jetbrains-mono" "m+" "ubuntu"] pkgs.nerd-fonts;
  fonts.fontconfig.useEmbeddedBitmaps = true; # ???
}
