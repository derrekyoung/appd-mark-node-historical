#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Global Constants
source ./config-mark-node-historical.ini

# Global Variables
APPLICATION_NAME=""
APPLICATION_ID=""
NODE_NAME=""
NODE_ID=""

################################################################################
# Logging
readonly LOG_FILE="$(basename "$0").log"
debug()   {
  if [ "$DEBUG_LOGS" = true ]; then
    echo -e "[DEBUG]   $@" | tee -a "$LOG_FILE" >&2
  fi
}
info()    { echo -e "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo -e "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo -e "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo -e "\n[FATAL]   $@\n" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

# Help
usage() {
  echo -e "USAGE: Mark a node as historical given the app and node names."
  echo -e "  $0 <APP_NAME> <NODE_NAME>"
  echo -e "Example:"
  echo -e "  $0 foobarApp node1"
  exit 0
}

################################################################################
# Prepare the tmp dir
prepare() {
  rm -rf "$LOG_FILE"
}

# Set the node ID to the global variable
set-node-id() {
  info "Getting the node ID for $NODE_NAME"

  if [ "$DEBUG_LOGS" = true ]; then
    output=$(curl --silent --user $USERNAME@$ACCOUNT:$PASSWORD $CONTROLLER/controller/rest/applications/$APPLICATION_NAME/nodes/"$NODE_NAME")
    debug "$output"
  fi

  local nodeId=`curl --silent --user "$USERNAME@$ACCOUNT:$PASSWORD" "$CONTROLLER/controller/rest/applications/$APPLICATION_NAME/nodes/$NODE_NAME" 2>&1 | grep -i "<id>" | cut -d'>' -f2 | cut -d'<' -f1`

  if [ -z "$nodeId" ]; then
    fatal "Unable to find the matching node ID. Application: '$APPLICATION_NAME', Node: '$NODE_NAME'"
  else
    NODE_ID="$nodeId"
    info "Node ID: $NODE_ID"
  fi
  # echo "$nodeId"
}

main() {
  prepare

  info "Starting... Application: '$APPLICATION_NAME', Node: '$NODE_NAME'"

  set-node-id

  info "Marking node as historical. Curl output:"

  curl -X POST --silent --user "$USERNAME@$ACCOUNT:$PASSWORD" "$CONTROLLER/controller/rest/mark-nodes-historical?application-component-node-ids=$NODE_ID" | tee -a "$LOG_FILE"

  echo -e ""
  info "Completed marking node as historical"
}

# Final function to be execution whether success or failure exit
cleanup() {
  # warning "Pipes exited with code: ${PIPESTATUS[@]}"
  info "Finished."
}

################################################################################
if [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

APPLICATION_NAME="$1"
NODE_NAME="$2"

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT
    main "$@"
fi
