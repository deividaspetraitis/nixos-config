{ pkgs }:

pkgs.writeShellScriptBin "update-host" ''
  set -e

  CONFIG_DIR="$HOME/nix-config"

  if [ ! -e "$CONFIG_DIR" ]; then
    echo "Error: $CONFIG_DIR does not exist, run initialize-host first."
    exit 1
  fi

  nix flake update --flake "$CONFIG_DIR" --commit-lock-file
''
