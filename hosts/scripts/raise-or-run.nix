{ pkgs }:

pkgs.writeShellScriptBin "raiseorrun" ''
    set -euo pipefail

    usage() {
      cat <<'EOF'
  Usage:
    raiseorrun [--title TITLE] [--app_id ID] [--match app_id|title|both]
               [--term TERM] [--term-args "ARGS..."] -- <command...>

  Examples:
    raiseorrun --title pulsemixer -- pulsemixer
    raiseorrun --app_id bluetuith --title bluetuith -- bluetuith
    raiseorrun --title btop --match app_id -- btop
    raiseorrun --term foot --term-args "-W 120 -H 40" --title nvim -- nvim
  EOF
    }

    TITLE=""
    APP_ID=""
    MATCH="both"
    TERM="${pkgs.foot}/bin/foot"
    TERM_ARGS=""

    # Parse options
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --title)
          [ "$#" -ge 2 ] || { echo "Missing value for --title" >&2; usage; exit 2; }
          TITLE="$2"; shift 2;;
        --app_id|--appid)
          [ "$#" -ge 2 ] || { echo "Missing value for --app_id" >&2; usage; exit 2; }
          APP_ID="$2"; shift 2;;
        --match)
          [ "$#" -ge 2 ] || { echo "Missing value for --match" >&2; usage; exit 2; }
          MATCH="$2"; shift 2;;
        --term)
          [ "$#" -ge 2 ] || { echo "Missing value for --term" >&2; usage; exit 2; }
          TERM="$2"; shift 2;;
        --term-args)
          [ "$#" -ge 2 ] || { echo "Missing value for --term-args" >&2; usage; exit 2; }
          TERM_ARGS="$2"; shift 2;;
        -h|--help)
          usage; exit 0;;
        --)
          shift; break;;
        -*)
          echo "Unknown option: $1" >&2
          usage; exit 2;;
        *)
          # First non-flag: treat the rest as command (allows omitting --)
          break;;
      esac
    done

    # Remaining args are the command
    if [ "$#" -lt 1 ]; then
      echo "Missing command." >&2
      usage
      exit 2
    fi

    # Defaults / validation
    if [ -z "$TITLE" ] && [ -z "$APP_ID" ]; then
      echo "You must set at least --title or --app_id." >&2
      usage
      exit 2
    fi
    if [ -z "$APP_ID" ]; then APP_ID="$TITLE"; fi
    if [ -z "$TITLE" ]; then TITLE="$APP_ID"; fi

    case "$MATCH" in
      app_id|title|both) ;;
      *)
        echo "Invalid --match value: $MATCH (expected app_id|title|both)" >&2
        exit 2;;
    esac

    # Build sway criteria + existence check
    CRITERIA=""
    case "$MATCH" in
      app_id) CRITERIA="[app_id=\"$APP_ID\"]";;
      title)  CRITERIA="[title=\"$TITLE\"]";;
      both)   CRITERIA="[app_id=\"$APP_ID\"], [title=\"$TITLE\"]";;
    esac

    # Check if a matching window exists
    if ${pkgs.sway}/bin/swaymsg -t get_tree \
        | grep -q "\"app_id\":\"$APP_ID\"\\|\"title\":\"$TITLE\"\\|\"name\":\"$TITLE\""; then
      ${pkgs.sway}/bin/swaymsg "$CRITERIA focus"
    else
      # shellcheck disable=SC2086
      exec "$TERM" -a "$APP_ID" -T "$TITLE" $TERM_ARGS "$@"
    fi
''
