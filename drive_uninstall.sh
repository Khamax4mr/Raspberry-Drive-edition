#!/bin/bash

readonly RUN_PATH="$(cd "$(dirname "$0")" && pwd)"
readonly PG_NAME="Raspberry-Drive Uninstaller"
readonly BASE_NAME="raspberry-drive"

set -e
source "$RUN_PATH/module/drive_common.sh"


# set values from command arguments
# $@: command arguments
_set_params() {
  if [[ "${1:-}" =~ (-h|--help) ]]; then
    _echo_help
  fi
}

# print descriptions then terminate
_echo_help() {
  printf "%s\n%s\n\n" "$PG_NAME"\
         "usage: sudo bash $(basename "$0") <path>"
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

  # prevent no drive
  if [ -z "$RASPBERRY_DRIVE_PATH" ]; then
    _echo_err "drive is not installed"
    exit 1
  fi

  # remove drive base
  if [[ -e "$RASPBERRY_DRIVE_PATH" ]]; then
    _echo_info "removing raspberry-drive base ..."
    rm -r "$RASPBERRY_DRIVE_PATH"
  else
    _echo_warn "no raspberry-drive base"
  fi

  # remove drive path
  _echo_info "removing raspberry-drive path ..."
  sed -i '/RASPBERRY_DRIVE_PATH/d' /etc/environment
  unset "$RASPBERRY_DRIVE_PATH"
  source ~/.bashrc

  # remove auto storage service
  _echo_info "removing auto storage management service ..."
  rm "/etc/systemd/system/raspberry-drive@.service"
  systemctl daemon-reload

  # remove auto device rule
  _echo_info "removing auto device handling rule ..."
  rm "/etc/udev/rules.d/99-raspberry-drive.rules"
  udevadm control --reload-rules
  udevadm trigger

  _echo_info "raspberry-drive successfully uninstalled!"
}

_main "$@"