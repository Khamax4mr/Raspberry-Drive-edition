#!/bin/bash

readonly RUN_PATH="$(cd "$(dirname "$0")" && pwd)"
readonly PG_NAME="Raspberry-Drive Unmount Module"

set -e
source "$RUN_PATH/drive_common.sh"

DEV_UUID=""


# set values from command arguments
# $@: command arguments
_set_params() {
  if [[ "${1:-}" =~ (-h|--help) ]]; then
    _echo_help
  fi

  # device uuid
  if [ -n "${1:-}" ]; then
    DEV_UUID="$1"
  fi
}

# print descriptions then terminate
_echo_help() {
  printf "%s\n%s\n\n" "$PG_NAME"\
    "usage: bash $(basename "$0") <uuid>"
  printf "%s\n%s\n" "description:" \
    "  <uuid>    device uuid"
  exit 0
}


_main() {
  # require running with sudo/root
  if [[ "$(id -u)" -ne 0 ]]; then
    _echo_err "sudo/root required: use 'sudo bash $0'"
    exit 1
  fi

  # set variables
  _set_params "$@"

  if [[ ! -e "$RASPBERRY_DRIVE_PATH/$DEV_UUID" ]]; then
    _echo_warn "no storage path of $DEV_UUID"
  else
    # unmount device
    if [[ -z "$(findmnt "$RASPBERRY_DRIVE_PATH/$DEV_UUID")" ]]; then
      _echo_warn "$DEV_UUID is already unmounted"
    else
      _echo_info "unmounting device ..."
      umount "$RASPBERRY_DRIVE_PATH/$DEV_UUID"
    fi
    
    # remove storage
    _echo_info "removing storage ..."
    rmdir "$RASPBERRY_DRIVE_PATH/$DEV_UUID"
  fi

  # remove umount script
  if [[ ! -e "$RASPBERRY_DRIVE_PATH/umount_$DEV_UUID.sh" ]]; then
    _echo_warn "no umount script of $DEV_UUID"
  else
    _echo_info "removing umount script ..."
    rm "$RASPBERRY_DRIVE_PATH/umount_$DEV_UUID.sh"
  fi
}

_main "$@"