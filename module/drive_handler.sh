#!/bin/bash

readonly RUN_PATH="$(cd "$(dirname "$0")" && pwd)"
readonly PG_NAME="Raspberry-Drive Service Management Module"
readonly VALID_ACTION=("create" "remove")

set -e
source "$RUN_PATH/drive_common.sh"

ACTION=""
ARGS=""


# set values from command arguments
# $@: command arguments
_set_params() {
  if [[ "${1:-}" =~ (-h|--help) ]]; then
    _echo_help
  fi
  
  # parse args from service
  if [[ "$@" == *"/"* ]]; then
    IFS="/" read -r ACTION ARGS <<< "$@"
  fi
}

# print descriptions then terminate
_echo_help() {
  printf "%s\n%s\n\n" "$PG_NAME"\
         "usage: bash $(basename "$0") <action> [args..]"
  printf "%s\n%s\n" "description:" \
         "  <action>  target script [${VALID_ACTION[*]}]"\
         "  [args..]  the other arguments for action"
  exit 0
}

_main() {
  # require running with sudo/root
  if [[ "$(id -u)" -ne 0 ]]; then
    _echo_err "sudo/root required: use 'sudo bash $0'"
    exit 1
  fi

  # run action
  _set_params "$@"

  case "$ACTION" in
    "create")  bash "$RUN_PATH/drive_create.sh" "$ARGS" ;;
    *)        _echo_err "invalid action: use [${VALID_ACTION[*]}]" ;;
  esac
}

_main "$@"