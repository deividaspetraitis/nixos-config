{ pkgs }:

pkgs.writeShellScriptBin "switch-home" ''
  set -e

  CONFIG_DIR="$HOME/nix-config"

  if [ ! -e "$CONFIG_DIR" ]; then
    echo "Error: $CONFIG_DIR does not exist, run initialize-host first."
    exit 1
  fi

  nix build --show-trace \
    "$CONFIG_DIR/.#homeManagerConfigurations.$USER.activationPackage" \
    --out-link "$CONFIG_DIR/result"

  "$CONFIG_DIR/result/activate"
''
