{ pkgs }:

pkgs.writeShellScriptBin "mpris-position" ''
  pos=$(playerctl --player=playerctld position 2>/dev/null) || exit 0
  [ -z "$pos" ] && exit 0


  s=$(printf "%.0f" "$pos")

  h=$(( s / 3600 ))
  m=$(( (s % 3600) / 60 ))
  sec=$(( s % 60 ))

  if [ "$h" -gt 0 ]; then
      printf "%02d:%02d:%02d\n" "$h" "$m" "$sec"
  else
      printf "%02d:%02d\n" "$m" "$sec"
  fi
''
