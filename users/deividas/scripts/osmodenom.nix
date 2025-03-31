{ pkgs }:

pkgs.writeShellScriptBin "osmodenom" ''
  if [ -z "$1" ]; then
    echo "Usage: $0 <denom>"
    exit 1
  fi

  DENOM="$1"
  URL="https://raw.githubusercontent.com/osmosis-labs/assetlists/main/osmosis-1/generated/frontend/assetlist.json"

  ${pkgs.curl}/bin/curl -s "$URL" | ${pkgs.jq}/bin/jq -r --arg denom "$DENOM" '
    .assets[] 
    | select(.variantGroupKey == $denom) 
  '
''
