{ pkgs }:

pkgs.writeShellScriptBin "osmostat" ''
  ${pkgs.curl}/bin/curl "https://rpc.osmosis.zone/status" -s | ${pkgs.jq}/bin/jq
''
