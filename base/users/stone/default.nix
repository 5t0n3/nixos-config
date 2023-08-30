{
  config,
  inputs,
  ...
}: {
  imports = [
    ./graphical
    inputs.nix-index-db.hmModules.nix-index
  ];

  # fish config
  programs.fish.enable = true;
  xdg.configFile."fish/fish_variables".source = ./fish_variables;

  # vis config
  xdg.configFile = {
    "vis/visrc.lua".source = ./vis/visrc.lua;
    "vis/lexers/nix.lua".source = ./vis/nix.lua;
    "vis/themes/gruvbox.lua".source = ./vis/gruvbox.lua;
  };

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

    userName = "5t0n3";
    userEmail = "31430937+5t0n3@users.noreply.github.com";

    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
      pull.rebase = true;
      fetch.prune = true;
    };
  };

  # nix-index-database enables nix-index by default for some reason
  # I only want it on on graphical machines
  programs.nix-index = let
    graphical = config.stone.graphical.enable;
  in {
    enable = graphical;
    symlinkToCacheHome = graphical;
  };

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "22.05";
}
