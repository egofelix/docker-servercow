#!/bin/bash

# Setup exception handling
set -uo pipefail

## Load Functions
source "${BASH_SOURCE%/*}/functions.sh"

# Check Variables
if [[ -z ${HOSTNAME:-} ]]; then
  HOSTNAME=$(cat /proc/sys/kernel/hostname)
fi;
if [[ -z ${HOSTNAME} ]]; then
  echo "Please provide HOSTNAME environment variable.";
  exit 1;
fi;
if [[ -z ${USERNAME:-} ]]; then
  echo "Please provide USERNAME environment variable.";
  exit 1;
fi;
if [[ -z ${PASSWORD:-} ]]; then
  echo "Please provide PASSWORD environment variable.";
  exit 1;
fi;
if [[ -z ${DOMAINS:-} ]]; then
  echo "Please provide DOMAINS environment variable.";
  exit 1;
fi;
if [[ -z ${TTL:-} ]]; then
  TTL="60";
fi;
if [[ -z ${QUIET:-} ]]; then
  QUIET="false";
fi;
if [[ -z ${UPDATE_IPV4:-} ]]; then
  UPDATE_IPV4="true";
fi;
if [[ -z ${UPDATE_IPV6:-} ]]; then
  UPDATE_IPV6="true";
fi;

# Trim Hostname (if it contains any .)
HOSTNAME=$(echo "${HOSTNAME}" | awk -F'.' '{print $1}')

# Main Loop
while true; do
  # Get current IPs
  IPV4=$(curl --silent ifconfig.me)
  IPV6=$(LANG=C ip addr list | grep 'inet6' | grep 'global' | awk '{print $2}' | awk -F'/' '{print $1}')

  for DOMAIN in ${DOMAINS}
  do
    if [[ ! -z "${IPV4}" ]] && [[ isTrue ${UPDATE_IPV4} ]]; then
      updateRecord "A" ${HOSTNAME} ${DOMAIN} ${IPV4};
    fi;
    if [[ ! -z "${IPV4}" ]] && [[ isTrue ${UPDATE_IPV6} ]]; then
      updateRecord "AAAA" ${HOSTNAME} ${DOMAIN} ${IPV6};
    fi;
    if [[ isTrue ${UPDATE_SSHFP} ]]; then

    fi;
  done;

  # Sleep 30 seconds
  sleep 30;
done;


