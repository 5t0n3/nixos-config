{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.stone.programs;
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    stone.programs = {
      all = mkEnableOption "all the things";
      dev = mkEnableOption "development programs";
      chat = mkEnableOption "programs for chatting";
      sec = mkEnableOption "security-related stuff (?)";
      prod = mkEnableOption "productivity stuff";
      ctf = mkEnableOption "CTF-related tools";
    };
  };

  config = lib.mkMerge [
    {
      # TODO: unhack
      programs.zoxide.enable = true;
    }
    (mkIf cfg.all {
      stone.programs = {
        dev = true;
        chat = true;
        prod = true;
        sec = true;
        ctf = true;
      };
    })
    (mkIf cfg.dev {
      home.packages =
        lib.attrVals [
          "nil"
          "alejandra"
        ]
        pkgs;

      # enable git (lol)
      programs.git.enable = true;

      # delta (git pager)
      programs.git.delta = {
        enable = true;
        options = {
          side-by-side = true;
        };
      };

      # (nix-)direnv stuff
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      nix.settings.keep-outputs = true;
    })
    (mkIf cfg.sec {
      programs.rbw = {
        enable = true;
        settings = {
          email = "zane.othman@gmail.com";
          base_url = "https://vault.othman.io";
          pinentry = pkgs.pinentry-gnome3;
        };
      };
    })
    (mkIf cfg.chat {
      home.packages = [pkgs.dissent];
    })
    (mkIf cfg.prod {
      home.packages =
        lib.attrVals [
          "typst"
          "typst-lsp"
          "libreoffice"
          # "logseq"
          "reveal-md"
          "pympress"
        ]
        pkgs;

      programs.zathura.enable = true;
      programs.pandoc.enable = true;
      services.nextcloud-client.enable = true;
      services.nextcloud-client.startInBackground = true;
    })
    (mkIf cfg.ctf {
      # TODO: bring in blizzard stuff
      home.packages =
        lib.attrVals [
          "ghidra"
          "binutils"
        ]
        pkgs;
    })
  ];
}
