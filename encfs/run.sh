#!/usr/bin/env bash
set -e
ENC_PATH=/encrypted
DEC_PATH=/decrypted

mkdir -p $DEC_PATH

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Debug function with colorized output
debug() {
    if [ -n "$DEBUG" ]; then
      echo -e "${BLUE}[DEBUG] ${YELLOW} ${1}${RESET}"
    fi
}

info() {
  echo -e "${GREEN}${1}${RESET}"
}

error() {
  echo -e "${RED}[ERROR] ${1}${RESET}"
}

mask_string() {
  local str="$1"
  local mask_char="$2-=*"
  local masked_str=""

  for (( i=0; i<${#str}; i++ )); do
    if (( i % 2 == 0 )); then
      masked_str+="${str:$i:1}"
    else
      masked_str+="$mask_char"
    fi
  done

  echo "$masked_str"
}

function sigterm_handler {
  echo "sending SIGTERM to child pid"
  kill -s -SIGTERM ${pid}
  echo "Unmounting: mount ${DEC_FOLDER} at: $(date +%Y.%m.%d-%T)"
  fusermount3 -u "${DEC_PATH}"
  echo "exiting container now"
  exit $?
}


function sighup_handler {
    echo "sending SIGHUP to child pid"
    kill -s -SIGHUP ${pid}
    echo "exiting..."
    wait ${pid}
}


trap sigterm_handler SIGINT SIGTERM
trap sighup_handler SIGHUP

debug "$(mask_string "$PASSWD")"

_user="$(id -u -n)"
_uid="$(id -u)"
debug "Running as $_user with UID: $_uid"

unset pid

if [ ! -f "$ENC_PATH/.encfs6.xml" ]; then
  info "$ENC_PATH is not valid encfs volume"
  exit 1
fi

if [ ! -z "$PASSWD" ]; then
  debug "mounting ${ENC_PATH} on ${DEC_PATH}"
  echo $PASSWD | encfs --stdinpass -o ${MOUNT_OPTIONS} -f "${ENC_PATH}" "${DEC_PATH}" & pid=($!)
else
  debug "mounting without password"
	encfs ${ENCFS_OPTS} -o ${MOUNT_OPTIONS} -f "${ENC_PATH}" "${DEC_PATH}" & pid=($!)
fi
info "Process: ${pid} started successfully"
wait "${pid}"

error "encfs crashed at: $(date +%Y.%m.%d-%T)"
info "Unmounting: ${DEC_FOLDER} at: $(date +%Y.%m.%d-%T)"
fusermount -u "${DEC_PATH}"
exit $?
