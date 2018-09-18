#!/bin/sh
set -e

export HOSTNAME=$(echo "$VCAP_APPLICATION" | cut -d'[' -f2 | cut -d']' -f1 | tr -d '"')

${LCSRV_HOME}/bin/license-server.sh configure \
		--listen 0.0.0.0 \
		--port 8111 \
		--jetty.virtualHosts.names=$HOSTNAME \
		--temp-dir ${LCSRV_HOME}/temp

exec /register.sh run &
exec ${LCSRV_HOME}/bin/license-server.sh run
