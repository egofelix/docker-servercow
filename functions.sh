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
  local TARGET_SUBDOMAIN="$2"
  local TARGET_DOMAIN="$3"
  local TARGET_IP="$4"
  local EXPECTEDRESULT="{\"message\":\"ok\"}"

#  echo "Update Record: \"${TARGET_RECORD}\", \"${TARGET_SUBDOMAIN}\", \"${TARGET_DOMAIN}\", \"${TARGET_IP}\"...";

  if [[ -z "${TARGET_SUBDOMAIN}" ]]; then
    local FULL_DOMAIN="${TARGET_DOMAIN}";
  else
    local FULL_DOMAIN="${TARGET_SUBDOMAIN}.${TARGET_DOMAIN}";
  fi;

  if [[ -z "${TARGET_IP}" ]]; then
    echo "Missing Parameter #4: TARGET_IP";
    return 1;
  fi;

  # Check if current ip matchs
  local CURRENT_IP=$(dig ${FULL_DOMAIN} ${TARGET_RECORD} +short)
  if [[ "${CURRENT_IP}" = "${TARGET_IP}" ]]; then
    logLine "${TARGET_RECORD}-Record of \"${FULL_DOMAIN}\" is up to date.";
    return 0;
  else
    logLine "Updating ${TARGET_RECORD}-Record of \"${FULL_DOMAIN}\" with ${TARGET_IP}...";
    local RESULT=$(curl --silent -X POST "https://api.servercow.de/dns/v1/domains/${TARGET_DOMAIN}" \
                           -H "X-Auth-Username: ${USERNAME}" \
                           -H "X-Auth-Password: ${PASSWORD}" \
                           -H "Content-Type: application/json" \
                           --data "{\"type\":\"${TARGET_RECORD}\",\"name\":\"${TARGET_SUBDOMAIN}\",\"content\":\"${TARGET_IP}\",\"ttl\":${TTL}}")
    if [[ "${RESULT}" = "${EXPECTEDRESULT}" ]]; then
      logLine "Updated";
      return 0;
    else
      echo "Failed to update ${TARGET_RECORD}-Record of host \"${FULL_DOMAIN}\" with \"${TARGET_IP}\": ${RESULT}";
      return 1;
    fi;
  fi;
}
