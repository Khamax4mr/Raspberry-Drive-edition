#!/bin/bash

readonly RUN_PATH="$(cd "$(dirname "$0")" && pwd)"
readonly PG_NAME="Raspberry-Drive Storage Creation Module"

set -e
source "$RUN_PATH/drive_common.sh"

DEV_NAME=""


# set values from command arguments
# $@: command arguments
_set_params() {
  if [[ "${1:-}" =~ (-h|--help) ]]; then
    _echo_help
  fi

  # device name
  if [ -n "${1:-}" ]; then
    DEV_NAME="$1"
  fi
}

# print descriptions then terminate
_echo_help() {
  printf "%s\n%s\n\n" "$PG_NAME"\
         "usage: bash $(basename "$0") <name>"
  printf "%s\n%s\n" "description:" \
         "  <name>    device name"
  exit 0
}

# get device data like name, type, mountpoint, uuid
# $1: device name
_get_disk_info() {
  printf "$(lsblk -Jfo NAME,TYPE,MOUNTPOINT,UUID | jq '.blockdevices[] | select(.name=="'$1'")')"
}


_main() {
  # require running with sudo/root
  if [[ "$(id -u)" -ne 0 ]]; then
    _echo_err "sudo/root required: use 'sudo bash $0'"
    exit 1
  fi

  # set variables
  _set_params "$@"

  # prevent invalid device
  if [[ ! -e "/dev/$DEV_NAME" ]]; then
    _echo_err "no device path of $DEV_NAME"
    exit 1
  fi

  # get device data
  local info="$(_get_disk_info "$DEV_NAME")"
  local type="$(echo $info | jq -r '.type')"
  local target"=$(echo $info | jq -r '.mountpoint')"
  local uuid="$(echo $info | jq -r '.uuid')"

  # prevent no disk device
  if [[ "$type" != 'disk' ]]; then
    _echo_err "no disk $DEV_NAME"
    exit 1
  fi
  
  # prevent double mount
  if [[ "$target" != 'null' ]]; then
    _echo_err "$DEV_NAME is already mounted"
    exit 1
  fi

  # prevent unavailable uuid
  if [[ "$uuid" == 'null' ]]; then
    _echo_err "no uuid of $DEV_NAME"
    exit 1
  fi

  # create storage
  if [[ -e "$RASPBERRY_DRIVE_PATH/$uuid" ]]; then
    _echo_warn "$DEV_NAME mount path already exist"
  else
    _echo_info "creating storage $uuid ..."
    mkdir "$RASPBERRY_DRIVE_PATH/$uuid"
    chmod 750 "$RASPBERRY_DRIVE_PATH/$uuid"
  fi

  # create umount script
  _echo_info "creating unmount script of $uuid ..."
  printf "%s\n%s" "#!/bin/bash" "bash ./module/drive_remove.sh $uuid" > "$RASPBERRY_DRIVE_PATH/umount_$uuid.sh"
  chmod 750 "$RASPBERRY_DRIVE_PATH/umount_$uuid.sh"

  # mount storage
  _echo_info "mounting device ..."
  mount "/dev/$DEV_NAME" "$RASPBERRY_DRIVE_PATH/$uuid"

  _echo_info "$DEV_NAME is successfully mounted to $uuid"
}

_main "$@"