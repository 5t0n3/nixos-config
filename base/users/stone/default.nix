{
  pkgs,
  inputs,
  ...
}: {
  imports = [./graphical inputs.nix-index-db.hmModules.nix-index];

  home.packages = with pkgs; [vis du-dust];

  # fish config
  programs.fish.enable = true;
  xdg.configFile."fish/fish_variables".source = ./fish_variables;

  # vis config
  xdg.configFile = {
    "vis/visrc.lua".source = ./vis/visrc.lua;
    "vis/lexers/nix.lua".source = ./vis/nix.lua;
    "vis/themes/gruvbox.lua".source = ./vis/gruvbox.lua;
  };

  # direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.nix-index.enable = true;

  # misc command line utilities
  programs.bat = {
    enable = true;
    config = {theme = "Nord";};
  };
  programs.bottom.enable = true;
  programs.zoxide.enable = true;
  programs.git = {
    enable = true;
    # TODO: figure out delta theming
    delta.enable = true;

    userName = "Zane Othman";
    userEmail = "zane.othman@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
      pull.rebase = true;
      fetch.prune = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "22.05";
}
