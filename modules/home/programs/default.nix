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
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          side-by-side = true;
        };
      };

      # (nix-)direnv stuff
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
    })
    (mkIf cfg.sec {
      home.packages = [pkgs.pinentry-gnome3 pkgs.bitwarden-desktop];
    })
    (mkIf cfg.chat {
      home.packages = [pkgs.thunderbird];
    })
    (mkIf cfg.prod {
      home.packages =
        lib.attrVals [
          "typst"
          "tinymist"
          "harper"
          "libreoffice"
          "reveal-md"
          "anki"
          "gimp3"
          # "pympress"
          # "logseq"
        ]
        pkgs;

      programs.zathura.enable = true;
      services.nextcloud-client.enable = true;
      services.nextcloud-client.startInBackground = true;
    })
    (mkIf cfg.ctf {
      home.packages =
        lib.attrVals [
          "ghidra"
          "binutils"
        ]
        pkgs;
    })
  ];
}
