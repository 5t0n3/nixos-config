pkgs: deployNodes: let
  inherit (pkgs.lib) concatStringsSep mapAttrsToList;
  deployList =
    concatStringsSep " "
    (mapAttrsToList (name: host: "[${name}]=${host}") deployNodes);
  deploy-sh = pkgs.writeShellApplication {
    name = "deploy-sh";

    runtimeInputs = builtins.attrValues {
      inherit (pkgs) nixos-rebuild gnugrep git nix-output-monitor;
    };
    text = ''
      declare -A machines
      machines=(${deployList})

      # basic usage cause why not
      if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
        echo "Usage: deploy <host> [-f]"
        echo -n "Valid deployment targets: "
        echo "''${!machines[@]}"
        exit 1
      fi

      # ensure a valid host was provided
      target="''${machines[$1]:-invalid}"
      if [ "$target" = "invalid" ]; then
        echo -n "Please specify a valid deployment host! Your choices are: "
        echo "''${!machines[@]}"
        exit 1

      # clean working tree deployment
      elif git diff-index --quiet HEAD; then
        revstr="$(git rev-parse --short HEAD)"
        printf "Deploying configuration version \e[0;92m%s\e[0m to \e[1;97m%s\e[0m!\n" "$revstr" "$1"
        nixos-rebuild switch --target-host "$target" --fast --use-remote-sudo --flake ".#$1" |& nom

      # Forced dirty deployment with fancy colors :)
      elif [ $# -eq 2 ] && [ "$2" = "-f" ]; then
        printf "\e[1;91mWARNING!\e[0m"
        printf " Deploying uncommitted configuration version to \e[1;97m%s\e[0m!\n" "$1"
        nixos-rebuild switch --target-host "$target" --fast --use-remote-sudo --flake ".#$1" |& nom

      # dirty working tree warning
      else
        echo "Commit your changes before deploying! (or provide the -f flag)"
      fi
    '';
  };
  updatecheck = pkgs.writeShellApplication {
    name = "updatecheck";

    runtimeInputs = builtins.attrValues {
      inherit (pkgs) openssh git jq;
    };

    text = ''
      declare -A machines
      machines=(${deployList})

      # colors yay
      red="\e[1;31m"
      reset="\e[0m"

      # nix string interpolation escaping is fun :)
      for host in "''${!machines[@]}"; do
        # obtain configuration commit hash
        rev=$(ssh "''${machines[$host]}" "nixos-version --json" | jq -r .configurationRevision)
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
