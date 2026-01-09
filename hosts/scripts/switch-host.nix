{ pkgs }:

pkgs.writeShellScriptBin "switch-host" ''
  set -e

  CONFIG_DIR="$HOME/nix-config"

  if [ ! -e "$CONFIG_DIR" ]; then
    echo "Error: $CONFIG_DIR does not exist, run initialize-host first."
    exit 1
  fi

  sudo nixos-rebuild switch --flake "$CONFIG_DIR/.#"
''
