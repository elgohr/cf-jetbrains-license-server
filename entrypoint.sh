#!/bin/sh
set -e

export HOSTNAME=$(echo "$VCAP_APPLICATION" | jq '.application_uris|@csv' | tr -d '"' | tr -d '\\')

${USER_HOME}/license-server/bin/license-server.sh configure \
		--listen 0.0.0.0 \
		--port 8111 \
		--jetty.virtualHosts.names=$HOSTNAME \
		--temp-dir ${USER_HOME}/license-server/temp

exec ${USER_HOME}/register.sh run &
exec ${USER_HOME}/license-server/bin/license-server.sh run
