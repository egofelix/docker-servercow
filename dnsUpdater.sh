#!/bin/bash

# Setup exception handling
set -uo pipefail

## Load Functions
source "${BASH_SOURCE%/*}/functions.sh"

# Check Variables
if [[ -z ${USERNAME:-} ]]; then
  echo "Please provide USERNAME environment variable.";
  exit 1;
fi;
if [[ -z ${PASSWORD:-} ]]; then
  echo "Please provide PASSWORD environment variable.";
  exit 1;
fi;
if [[ -z ${HOSTNAMES:-} ]]; then
  if [[ -z ${HOSTNAME:-} ]]; then
    HOSTNAME=$(cat /proc/sys/kernel/hostname)
  fi;
  if [[ -z ${HOSTNAME} ]]; then
    echo "Please provide HOSTNAME environment variable.";
    exit 1;
  fi;
  if [[ -z ${DOMAINS:-} ]]; then
    echo "Please provide DOMAINS environment variable.";
    exit 1;
  fi;

  # Trim Hostname (if it contains any .)
  HOSTNAME=$(echo "${HOSTNAME}" | awk -F'.' '{print $1}')
  HOSTNAMES=()

  for DOMAIN in ${DOMAINS}
  do
    HOSTNAMES+=(${HOSTNAME}.${DOMAIN})
  done;

  HOSTNAMES="${HOSTNAMES[@]}"
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

logLine "Hostnames: ${HOSTNAMES}";

# Main Loop
while true; do

  # Get current IPs
  IPV4=$(curl --silent ifconfig.me)
  IPV6=$(LANG=C ip addr list | grep 'inet6' | grep 'global' | grep -v 'private' | grep -v 'deprecated' | awk '{print $2}' | awk -F'/' '{print $1}' | grep -v '2001:')

  # Loop over hostnames
  for HOST in ${HOSTNAMES}
  do
    logLine "${HOST}";
    POINTCOUNT=$(echo ${HOST} | awk -F'.' '{print NF-1}');
    if [[ ${POINTCOUNT} == 1 ]]; then
      SUBDOMAIN="";
      DOMAIN="${HOST}";
    elif [[ ${POINTCOUNT} == 2 ]]; then
      SUBDOMAIN=$(echo ${HOST} | awk -F'.' '{print $1}');
      DOMAIN=$(echo ${HOST} | cut -d'.' -f2-);
    else
      logLine "Unsupported Hostname: ${HOST}";
      continue;
    fi;

    if isTrue ${UPDATE_IPV4} && [[ ! -z "${IPV4}" ]]; then
      updateRecord "A" "${SUBDOMAIN}" "${DOMAIN}" "${IPV4}";
    fi;
    if isTrue ${UPDATE_IPV6} && [[ ! -z "${IPV6}" ]]; then
      updateRecord "AAAA" "${SUBDOMAIN}" "${DOMAIN}" "${IPV6}";
    fi;
  done;

  # Sleep TTL seconds
  sleep ${TTL};
done;
