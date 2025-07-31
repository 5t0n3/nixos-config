{
  pkgs,
  lib,
  ...
}: let
  # bat configuration file
  bat-config = pkgs.writeText "batconfig" ''
    --theme='Nord'
  '';
in {
  imports = [
    ./openssh.nix
    ./nix.nix
    ./users.nix
  ];

  # home manager stuffs
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # base system packages
  environment.systemPackages =
    lib.attrVals [
      "vis"
      "helix"
      "du-dust"
      "lsd"
      "ripgrep"
      "bottom"
      "bat"
      "file"
      "hexyl"
      "bind"
      "inetutils"
    ]
    pkgs;

  # global git config
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      core.autocrlf = "input";
      merge.conflictStyle = "diff3";
      diff.renames = "copy";
      fetch.prune = true;
    };
  };

  # system-level vis configuration
  # TODO: do these even like work? it's been years
  environment.etc = {
    "vis/visrc.lua".source = ./vis/visrc.lua;
    "vis/lexers/nix.lua".source = ./vis/nix.lua;
    "vis/themes/gruvbox.lua".source = ./vis/gruvbox.lua;
  };

  # common environment variables (and also bat config file)
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    BAT_CONFIG_PATH = "${bat-config}";
  };

  # command-not-found doesn't work with flakes, so I just disable it
  programs.command-not-found.enable = false;

  # disable nix-index-db, what I replace it with, by default
  programs.nix-index.enable = false;

  # other miscellaneous settings
  time.timeZone = "America/Los_Angeles";
  boot.tmp.cleanOnBoot = true;

  # TODO: remove?
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = ["wheel"];
        noPass = false;
        keepEnv = true;
      }
    ];
  };
}
