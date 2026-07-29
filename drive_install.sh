#!/bin/bash

readonly RUN_PATH="$(cd "$(dirname "$0")" && pwd)"
readonly PG_NAME="Raspberry-Drive Installer"
readonly BASE_NAME="raspberry-drive"

set -e
source "$RUN_PATH/module/drive_common.sh"

BASE_PATH="/usr/local/share/$BASE_NAME"


# set values from command arguments
# $@: command arguments
_set_params() {
  if [[ "${1:-}" =~ (-h|--help) ]]; then
    _echo_help
  fi
  
  # installation path
  if [ -n "${1:-}" ]; then
    BASE_PATH="$1/$BASE_NAME"
    if [[ "$BASE_PATH" != /* ]]; then
      BASE_PATH="$(pwd)/$1/$BASE_NAME"
    fi
  fi
}

# print descriptions then terminate
_echo_help() {
  printf "%s\n%s\n\n" "$PG_NAME"\
         "usage: sudo bash $(basename "$0") <path>"
  printf "%s\n%s\n\n" "description:"\
         "  <path>    installation path"
  exit 0
}

# print installation setting
_echo_setting() {
  printf "%s\n" "[Raspberry-Drive Install Setting]"
  printf "%s\n\n" "drive path: $BASE_PATH"
}

# ask user to continue or abort
_ask() {
  read -p "Continue? (y/n): " ans
  case "$ans" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) exit 0 ;;
  esac
}


_main() {
  # require running with sudo/root
  if [[ "$(id -u)" -ne 0 ]]; then
    _echo_err "sudo/root required: use 'sudo bash $0'"
    exit 1
  fi

  # set variables
  _set_params "$@"
  _echo_setting
  _ask

  # prevent overwriting
  if [ -n "$RASPBERRY_DRIVE_PATH" ]; then
    if [ "$RASPBERRY_DRIVE_PATH" != "$BASE_PATH" ]; then
      _echo_err "drive is already installed: $RASPBERRY_DRIVE_PATH"
      exit 1
    fi
  fi

  # get package
  _echo_info "installing related package ..."
  # apt-get install -qq -y <package>

  # create drive base
  if [[ -e "$BASE_PATH" ]]; then
    _echo_warn "raspberry-drive base already exists"
  else
    _echo_info "creating raspberry-drive base ..."
    mkdir -p "$BASE_PATH"
  fi

  # copy drive script  
  _echo_info "copying raspberry-drive modules ..."
  cp -r "$RUN_PATH"/module "$BASE_PATH"

  # export drive path
  _echo_info "exporting raspberry-drive path ..."
  sed -i '/RASPBERRY_DRIVE_PATH/d' /etc/environment
  echo "RASPBERRY_DRIVE_PATH=\"$BASE_PATH\"" >> /etc/environment
  source /etc/environment

  _echo_info "raspberry-drive successfully installed!"
}

_main "$@"