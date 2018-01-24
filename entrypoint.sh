#!/bin/bash
set -e

export HOSTNAME=$(echo "$VCAP_APPLICATION" | cut -d'[' -f2 | cut -d']' -f1 | tr -d '"')

${LCSRV_HOME}/bin/license-server.sh configure \
		--listen 0.0.0.0 \
		--port 8111 \
		--jetty.virtualHosts.names=$HOSTNAME \
		--logs-dir ${LCSRV_HOME}/logs \
		--temp-dir ${LCSRV_HOME}/temp

exec ${LCSRV_HOME}/bin/license-server.sh run
