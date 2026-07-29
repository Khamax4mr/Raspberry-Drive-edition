#!/bin/bash

# print "[ INFO ] $1" message
# $1: message content
_echo_info() {
  local header="[\033[0;32m INFO \033[0m]"
  echo -e "$header $1"
}

# print "[ WARN ] $1" message
# $1: message content
_echo_warn() {
  local header="[\033[0;33m WARN \033[0m]"
  echo -e "$header $1"
}

# print "[FAILED] $1" message
# $1: message content
_echo_err() {
  local header="[\033[0;31mFAILED\033[0m]"
  echo -e "$header $1"
}