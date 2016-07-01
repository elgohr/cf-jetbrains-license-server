#!/bin/bash
set -e

${LCSRV_HOME}/bin/license-server.sh configure \
		--listen 0.0.0.0 \
		--port 8111 \
		--jetty.virtualHosts.names=$(echo "$VCAP_APPLICATION" | cut -d'[' -f2 | cut -d']' -f1) \
		--logs-dir ${LCSRV_HOME}/logs \
		--temp-dir ${LCSRV_HOME}/temp \
		--access.config=file:${LCSRV_HOME}/access-config.json

exec ${LCSRV_HOME}/bin/license-server.sh run
