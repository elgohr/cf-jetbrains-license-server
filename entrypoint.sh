#!/bin/sh
set -e

export HOSTNAME=$(echo "$VCAP_APPLICATION" | jq '.application_uris|@csv' | tr -d '"' | tr -d '\\')

${LCSRV_HOME}/bin/license-server.sh configure \
		--listen 0.0.0.0 \
		--port 8111 \
		--jetty.virtualHosts.names=$HOSTNAME \
		--temp-dir ${LCSRV_HOME}/temp

exec /register.sh run &
exec ${LCSRV_HOME}/bin/license-server.sh run
