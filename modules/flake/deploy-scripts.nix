pkgs: deployNodes: let
  deployList = pkgs.lib.concatMapStringsSep "\n" (str: " - " + str) deployNodes;
  deployRegex = "(${pkgs.lib.concatStringsSep "|" deployNodes})";
  # honestly I have no idea why I did this...I'll probably move back to deploy-rs at some point
  deploy-sh = pkgs.writeShellApplication {
    name = "deploy";

    runtimeInputs = builtins.attrValues {
      inherit (pkgs) nixos-rebuild gnugrep git nix-output-monitor;
    };
    text = ''
      # basic usage cause why not
      if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
        echo "Usage: deploy <host> [-f]"
        echo "Deployment targets:"
        echo "${deployList}"
      # ensure a valid host was provided
      elif echo "$1" | grep -qvE "${deployRegex}"; then
        echo "Please specify a valid deployment host! Your choices are:"
        echo "${deployList}"
      # clean working tree deployment
      elif git diff-index --quiet HEAD; then
        revstr=$(git rev-parse --short HEAD)
        printf "Deploying configuration version \e[0;92m%s\e[0m to \e[1;97m%s\e[0m!\n" "$revstr" "$1"
        nixos-rebuild switch --target-host "$1.localdomain" --fast --use-remote-sudo --flake ".#$1" |& nom
      # Forced dirty deployment with fancy colors :)
      elif [ $# -eq 2 ] && [ "$2" = "-f" ]; then
        printf "\e[1;91mWARNING!\e[0m"
        printf " Deploying uncommitted configuration version to \e[1;97m%s\e[0m!\n" "$1"
        nixos-rebuild switch --target-host "$1.localdomain" --fast --use-remote-sudo --flake ".#$1" |& nom
      # dirty working tree warning
      else
        echo "Commit your changes before deploying! (or provide the -f flag)"
      fi
    '';
  };
  deployListSpaces = pkgs.lib.concatStringsSep " " deployNodes;
  updatecheck = pkgs.writeShellApplication {
    name = "updatecheck";

    runtimeInputs = builtins.attrValues {
      inherit (pkgs) openssh git jq;
    };

    text = ''
      hosts=(${deployListSpaces})

      # colors yay
      red="\e[1;31m"
      reset="\e[0m"

      # nix string interpolation escaping is fun :)
      for host in "''${hosts[@]}"; do
        # obtain configuration commit hash
        rev=$(ssh "$host" "nixos-version --json" | jq -r .configurationRevision)
        shortRev=$(git rev-parse --short "$rev")

        # count intervening commits
        commitsSince=$(git rev-list --count "$shortRev..HEAD")

        echo -n "$host: "

        if [ "$commitsSince" != 0 ]; then
          echo -e "$red$commitsSince commits out of date$reset ($shortRev)"
        else
          echo "up to date"
        fi
      done
    '';
  };
in [deploy-sh updatecheck]
