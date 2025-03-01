{ pkgs }:

pkgs.writeShellScriptBin "osmostat" ''
  ${pkgs.curl}/bin/curl "https://rpc.osmosis.zone/status" -s | ${pkgs.jq}/bin/jq --arg key "$@" '
    . as $orig |  # Keep the original JSON
    reduce paths(scalars) as $p ({}; 
      if ($p[-1] | test($key)) then 
        setpath($p; $orig | getpath($p)) 
      else . end
    )'
''
