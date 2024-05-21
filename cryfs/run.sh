#!/bin/bash
set -e

ENC_PATH=`realpath "/encrypted"`
DEC_PATH=`realpath "/decrypted"`

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Debug function with colorized output
debug() {
  echo -e "${BLUE}[DEBUG] ${1}${RESET}"
}

mask_string() {
  local str="$1"
  local mask_char="$2"
  mask_char="${mask_char:-"*"}"
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
  kill -SIGTERM ${pid}
  echo "Unmounting: mount ${DEC_PATH} at: $(date +%Y.%m.%d-%T)"
  cryfs_unmount "${DEC_PATH}"
  echo "exiting container now"
  exit $?
}

function sighup_handler {
    echo "sending SIGHUP to child pid"
    kill -SIGHUP ${pid}
    wait ${pid}
}

function check_mount {
  # Check if a directory is mounted
  directory=$1
  # Use findmnt to check if the directory is mounted
  if findmnt --target "$directory" > /dev/null; then
      echo "Directory '$directory' is mounted."
  else
      echo "Directory '$directory' is not mounted."
  fi
}


trap sigterm_handler SIGINT SIGTERM
trap sighup_handler SIGHUP

_user="$(id -u -n)"
_uid="$(id -u)"
debug "Running as $_user with UID: $_uid"

if [ ! -z "$DEBUG" ]; then
  check_mount "/encrypted"
  debug "Checking files at ${ENC_PATH}"
  tree -L 1 ${ENC_PATH}
fi
unset pid
sleep infinity
if [ ! -z "$PASSWD" ]; then
  debug "mounting ${ENC_PATH} on ${DEC_PATH} via password:$(mask_string "$PASSWD")"
  echo ${PASSWD} | cryfs -o ${MOUNT_OPTIONS} -f "${ENC_PATH}" "${DEC_PATH}" & pid=$!
else
  echo -e "${RED}Fatal error: PASSWD variable is empty.${RESET}"
  exit 1
fi
echo 'File system is now mounted at ${ENC_PATH}'
wait "${pid}"


echo "cryfs crashed at: $(date +%Y.%m.%d-%T)"
echo "Unmounting: ${DEC_FOLDER} at: $(date +%Y.%m.%d-%T)"
cryfs_unmount "${DEC_PATH}"
echo "exiting container now"

exit $?
