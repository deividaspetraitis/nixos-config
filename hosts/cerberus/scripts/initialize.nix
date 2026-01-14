{ pkgs }:

pkgs.writeShellScriptBin "initialize-host" ''
  CONFIG_DIR="$HOME/nix-config"

  if [ -e "$CONFIG_DIR" ]; then
    echo "Error: $CONFIG_DIR already exists."
    exit 1
  fi

  git clone "https://github.com/deividaspetraitis/nixos-config.git" "$CONFIG_DIR"
''

