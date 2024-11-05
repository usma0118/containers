#!/bin/sh
set -e
ENC_PATH=/encrypted
DEC_PATH=/decrypted

mkdir -p "$DEC_PATH"

# Define colors using printf-compatible escape sequences
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Debug function with colorized output
debug() {
    if [ -n "$DEBUG" ]; then
      printf "${BLUE}[DEBUG] ${YELLOW}%s${RESET}\n" "$1"
    fi
}

info() {
  printf "${GREEN}%s${RESET}\n" "$1"
}

error() {
  printf "${RED}[ERROR] %s${RESET}\n" "$1"
}

mask_string() {
  str="$1"
  mask_char="${2:=-*}"
  masked_str=""
  i=0

  while [ $i -lt ${#str} ]; do
    char=$(printf "%s" "$str" | cut -c$((i+1)))
    if [ $((i % 2)) -eq 0 ]; then
      masked_str="$masked_str$char"
    else
      masked_str="$masked_str$mask_char"
    fi
    i=$((i + 1))
  done

  echo "$masked_str"
}

sigterm_handler() {
  echo "sending SIGTERM to child pid"
  kill -s TERM "$pid"
  echo "Unmounting: mount ${DEC_FOLDER} at: $(date +%Y.%m.%d-%T)"
  fusermount -u "$DEC_PATH"
  echo "exiting container now"
  exit $?
}

sighup_handler() {
    echo "sending SIGHUP to child pid"
    kill -s HUP "$pid"
    echo "exiting..."
    wait "$pid"
}

trap sigterm_handler INT TERM
trap sighup_handler HUP

debug "$(mask_string "$PASSWD")"

_user="$(id -u -n)"
_uid="$(id -u)"
debug "Running as $_user with UID: $_uid"

unset pid

if [ ! -f "$ENC_PATH/.encfs6.xml" ]; then
  info "$ENC_PATH is not valid encfs volume"
  exit 1
fi

if [ -n "$PASSWD" ]; then
  debug "mounting ${ENC_PATH} on ${DEC_PATH}"
  echo "$PASSWD" | encfs --stdinpass -o "$MOUNT_OPTIONS" -f "$ENC_PATH" "$DEC_PATH" & pid=$!
else
  debug "mounting without password"
  encfs "$ENCFS_OPTS" -o "$MOUNT_OPTIONS" -f "$ENC_PATH" "$DEC_PATH" & pid=$!
fi
info "Process: ${pid} started successfully"
wait "$pid"

error "encfs crashed at: $(date +%Y.%m.%d-%T)"
info "Unmounting: ${DEC_FOLDER} at: $(date +%Y.%m.%d-%T)"
fusermount -u "$DEC_PATH"
exit $?
