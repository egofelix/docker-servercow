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
  QUIET="false"
fi;

# Trim Hostname (if it contains any .)
HOSTNAME=$(echo "${HOSTNAME}" | awk -F'.' '{print $1}')

# Get current IPs
IPV4=$(curl --silent ifconfig.me)
IPV6=$(LANG=C ip addr list | grep 'inet6' | grep 'global' | awk '{print $2}' | awk -F'/' '{print $1}')

# Main Loop
while true; do
  for DOMAIN in ${DOMAINS}
  do
    if [[ ! -z "${IPV4}" ]]; then
      updateRecord "A" ${HOSTNAME} ${DOMAIN} ${IPV4};
    fi;
    if [[ ! -z "${IPV6}" ]]; then
      updateRecord "AAAA" ${HOSTNAME} ${DOMAIN} ${IPV6};
    fi;
  done;

  # Sleep 30 seconds
  sleep 30;
done;


