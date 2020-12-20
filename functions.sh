#!/bin/bash

function isTrue {
  if [[ "${1^^}" = "YES" ]]; then return 0; fi;
  if [[ "${1^^}" = "TRUE" ]]; then return 0; fi;
  return 1;
}

function logLine {
  if ! isTrue "${QUIET}"; then
    echo $@
  fi;
}

function updateRecord {
  local TARGET_RECORD="$1"
  local TARGET_HOSTNAME="$2"
  local TARGET_DOMAIN="$3"
  local TARGET_IP="$4"
  local EXPECTEDRESULT="{\"message\":\"ok\"}"

  if [[ -z "${TARGET_IP}" ]]; then
    echo "Cannot update ${TARGET_RECORD}-Record of ${TARGET_HOSTNAME}.${TARGET_DOMAIN} without a ip ${TARGET_IP}";
    return 1;
  fi;

  # Check if current ip matchs
  local CURRENT_IP=$(dig ${TARGET_HOSTNAME}.${TARGET_DOMAIN} ${TARGET_RECORD} +short)
  if [[ "${CURRENT_IP}" = "${TARGET_IP}" ]]; then
    logLine "${TARGET_RECORD}-Record of \"${HOSTNAME}.${DOMAIN}\" is up to date.";
    return 0;
  else
    logLine "Updating ${TARGET_RECORD}-Record of ${TARGET_HOSTNAME}.${TARGET_DOMAIN} with ${TARGET_IP}...";
    local RESULT=$(curl --silent -X POST "https://api.servercow.de/dns/v1/domains/${TARGET_DOMAIN}" \
                           -H "X-Auth-Username: ${USERNAME}" \
                           -H "X-Auth-Password: ${PASSWORD}" \
                           -H "Content-Type: application/json" \
                           --data "{\"type\":\"${TARGET_RECORD}\",\"name\":\"${TARGET_HOSTNAME}\",\"content\":\"${TARGET_IP}\",\"ttl\":${TTL}}")
    if [[ "${RESULT}" = "${EXPECTEDRESULT}" ]]; then
      logLine "Updated";
      return 0;
    else
      echo "Failed to update ${TARGET_RECORD}-Record of host \"${TARGET_HOSTNAME}.${TARGET_DOMAIN}\" with \"${TARGET_IP}\": ${RESULT}";
      return 1;
    fi;
  fi;
}

