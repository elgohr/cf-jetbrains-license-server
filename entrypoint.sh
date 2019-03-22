#!/bin/sh
set -e

export HOSTNAME=$(echo "$VCAP_APPLICATION" | jq '.application_uris|@csv' | tr -d '"' | tr -d '\\')

export PROXY=""
if [ ! -z "$HTTP_PROXYHOST" ] && [ ! -z "$HTTP_PROXYPORT" ]; then
    PROXY="-J-Dhttp.proxyHost=$HTTP_PROXYHOST -J-Dhttp.proxyPort=$HTTP_PROXYPORT"
    if [ ! -z "$HTTP_PROXYUSER" ] && [ ! -z "$HTTP_PROXYPASSWORD" ]; then
        PROXY="$PROXY -J-Dhttp.proxyUser=$HTTP_PROXYUSER -J-Dhttp.proxyPassword=$HTTP_PROXYPASSWORD"
    fi
fi
if [ ! -z "$HTTPS_PROXYHOST" ] && [ ! -z "$HTTPS_PROXYPORT" ]; then
    PROXY="$PROXY -J-Dhttps.proxyHost=$HTTPS_PROXYHOST -J-Dhttps.proxyPort=$HTTPS_PROXYPORT"
    if [ ! -z "$HTTPS_PROXYUSER" ] && [ ! -z "$HTTPS_PROXYPASSWORD" ]; then
        PROXY="$PROXY -J-Dhttps.proxyUser=$HTTPS_PROXYUSER -J-Dhttps.proxyPassword=$HTTPS_PROXYPASSWORD"
    fi
fi

${USER_HOME}/license-server/bin/license-server.sh configure \
		--listen 0.0.0.0 \
		--port 8111 \
		--jetty.virtualHosts.names=${HOSTNAME} \
		--temp-dir ${USER_HOME}/license-server/temp \
		${PROXY} \
		${CUSTOM_OPTIONS}

exec ${USER_HOME}/register.sh run &
exec ${USER_HOME}/license-server/bin/license-server.sh run
