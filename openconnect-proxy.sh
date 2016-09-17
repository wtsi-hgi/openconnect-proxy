#!/bin/bash

set -euf -o pipefail

polipo proxyAddress=0.0.0.0 proxyPort=8123 socksParentProxy=localhost:11080 authCredentials=${PROXY_USERNAME}:${PROXY_PASSWORD} &
cat "${OPENCONNECT_PASSWORD_FILE}" | openconnect --script-tun --script "ocproxy -D 11080" -u ${OPENCONNECT_USERNAME} -g ${OPENCONNECT_GROUP} --passwd-on-stdin ${OPENCONNECT_HOST}
