{pkgs, lib, ...}: {
  imports = [
    ./hyprland.nix
  ];

  # nix-index go brr (also why do they default to enabling ugh)
  programs.nix-index.enable = lib.mkForce true;

  # install some fonts (I don't use a lot of these but eh)
  fonts.enableDefaultPackages = true;
  fonts.packages = [
    (pkgs.nerdfonts.override {
      fonts = ["JetBrainsMono" "MPlus" "Overpass" "Ubuntu" "IntelOneMono"];
    })
  ];
}
