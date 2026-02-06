{ pkgs }:

pkgs.writeShellScriptBin "mpris-volume" ''
  	PLAYER="playerctld"

  	vol=$(playerctl --player="$PLAYER" volume 2>/dev/null) || exit 0

  	# Some players return nothing
  	[ -z "$vol" ] && echo "-" && exit 0

  	# Convert 0.0–1.0 → percent
  	percent=$(awk "BEGIN { printf \"%d\", ($vol * 100 + 0.5) }")

  	awk "BEGIN { printf \"%d\n\", ($vol * 100 + 0.5) }"
''
