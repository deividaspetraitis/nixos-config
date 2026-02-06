{ pkgs }:

pkgs.writeShellScriptBin "mpris-scroll" ''
  PLAYER="playerctld"

  # when no active player then hide module
  playerctl --player="$PLAYER" status >/dev/null 2>&1 || exit 0

  get_line() {
    artist=$(playerctl --player="$PLAYER" metadata xesam:artist 2>/dev/null | head -n1)
    title=$(playerctl --player="$PLAYER" metadata xesam:title 2>/dev/null | head -n1)
    album=$(playerctl --player="$PLAYER" metadata xesam:album 2>/dev/null | head -n1)

    [ -z "$artist" ] && artist="Unknown"
    [ -z "$title" ] && title="Unknown"
    [ -z "$album" ] && title="Unknown"

    printf "%s - %s [ %s ]\n" "$artist" "$title" "$album"
  }

  export -f get_line

  zscroll -u true -U 1 -l 20 -d 0.2 -n true -e true \
    get_line
''
