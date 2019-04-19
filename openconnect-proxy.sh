#!/bin/bash

set -euf -o pipefail

if [[ (-n "${PROXY_USERNAME:-}") && (-n "${PROXY_PASSWORD:-}")  ]]; then
    echo "Setting up polipo with authentication ..."
    polipo proxyAddress=0.0.0.0 proxyPort=8123 socksParentProxy=localhost:11080 authCredentials=${PROXY_USERNAME}:${PROXY_PASSWORD} &
else
    echo "Setting up polipo without authentication ..."
    polipo proxyAddress=0.0.0.0 proxyPort=8123 socksParentProxy=localhost:11080 &
fi

TMP_PASSWORD_FILE=$(mktemp)
if [[ -n "${OPENCONNECT_PASSWORD:-}" ]]; then
    echo "${OPENCONNECT_PASSWORD}" > "${TMP_PASSWORD_FILE}"
elif [[ -n "${OPENCONNECT_PASSWORD_FILE}" ]]; then
    if [[ -r "${OPENCONNECT_PASSWORD_FILE}" ]]; then
        cat "${OPENCONNECT_PASSWORD_FILE}" > "${TMP_PASSWORD_FILE}"
    else 
        if [[ -e "${OPENCONNECT_PASSWORD_FILE}" ]]; then 
            >&2 echo "OPENCONNECT_PASSWORD_FILE ${OPENCONNECT_PASSWORD_FILE} exists but is not readable"
            exit 1
        else
            >&2 echo "OPENCONNECT_PASSWORD_FILE ${OPENCONNECT_PASSWORD_FILE} does not exist"
            exit 1
        fi
    fi
else
    >&2 echo "Must specify either OPENCONNECT_PASSWORD or OPENCONNECT_PASSWORD_FILE"
    exit 2
fi

if [[ -n "${OPENCONNECT_GROUP:-}" ]]; then
    if [[ (-n "${OPENCONNECT_NO_CERT_CHECK:-}") && ("$OPENCONNECT_NO_CERT_CHECK" = true) ]] ; then
        cat "${TMP_PASSWORD_FILE}" | openconnect --script-tun --script "ocproxy -D 11080" -u ${OPENCONNECT_USERNAME} -g ${OPENCONNECT_GROUP} --passwd-on-stdin --non-inter --no-cert-check ${OPENCONNECT_HOST}
    else
        cat "${TMP_PASSWORD_FILE}" | openconnect --script-tun --script "ocproxy -D 11080" -u ${OPENCONNECT_USERNAME} -g ${OPENCONNECT_GROUP} --passwd-on-stdin --non-inter ${OPENCONNECT_HOST}
    fi
else
    if [[ (-n "${OPENCONNECT_NO_CERT_CHECK:-}") && ("$OPENCONNECT_NO_CERT_CHECK" = true) ]] ; then
        cat "${TMP_PASSWORD_FILE}" | openconnect --script-tun --script "ocproxy -D 11080" -u ${OPENCONNECT_USERNAME} --passwd-on-stdin --non-inter --no-cert-check ${OPENCONNECT_HOST}
    else
        cat "${TMP_PASSWORD_FILE}" | openconnect --script-tun --script "ocproxy -D 11080" -u ${OPENCONNECT_USERNAME} --passwd-on-stdin --non-inter ${OPENCONNECT_HOST}
    fi
fi
