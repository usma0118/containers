#!/bin/bash
set -e
set -o nounset
declare -r ENC_PATH=/encrypted
declare -r DEC_PATH=/decrypted

# Define colors
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[0;33m'
declare -r BLUE='\033[0;34m'
declare -r RESET='\033[0m'

# Debug function with colorized output
debug() {
  echo -e "${BLUE}[DEBUG]${YELLOW} ${1}${RESET}"
}

# Debug function with colorized output
error() {
  echo -e "${RED}[ERROR]${YELLOW} ${1}${RESET}"
}

# Debug function with colorized output
info() {
  echo -e "${GREEN} ${1}${RESET}"
}

function sigterm_handler {
  info "sending SIGTERM to child pid"
  kill -SIGTERM ${pid}
  info "Unmounting: mount ${DEC_FOLDER} at: $(date +%Y.%m.%d-%T)"
  cryfs_unmount "${DEC_PATH}"
  info "exiting container now"
  exit $?
}


function sighup_handler {
    info "sending SIGHUP to child pid"
    kill -SIGHUP ${pid}
    wait ${pid}
}


trap sigterm_handler SIGINT SIGTERM
trap sighup_handler SIGHUP

_user="$(id -u -n)"
_uid="$(id -u)"
debug "Running as $_user with UID: $_uid"
unset pid
if [ ! -z "$PASSWD" ]; then
  info "mounting ${ENC_PATH} on ${DEC_PATH}"
  echo "${PASSWD}" | cryfs -o ${MOUNT_OPTIONS} -f "${ENC_PATH}" "${DEC_PATH}" & pid=($!)
else
	cryfs ${ENCFS_OPTS} -o ${MOUNT_OPTIONS} -f "${ENC_PATH}" "${DEC_PATH}" & pid=($!)
  info "mounting ${ENC_PATH} on ${DEC_PATH} without password"
fi
wait "${pid}"


error "cryfs crashed at: $(date +%Y.%m.%d-%T)"
info "Unmounting: ${DEC_FOLDER} at: $(date +%Y.%m.%d-%T)"
cryfs_unmount "${DEC_PATH}"
info "exiting container now"

exit $?
