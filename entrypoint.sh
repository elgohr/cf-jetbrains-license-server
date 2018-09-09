#!/bin/sh
set -e

export HOSTNAME=$(echo "$VCAP_APPLICATION" | cut -d'[' -f2 | cut -d']' -f1 | tr -d '"')

contains_comma()
{
  case "$1" in
    *,*) return 0 ;;
    *) return 1 ;;
  esac
}

if [ -z "$SERVER_HOSTNAME" ] && contains_comma $HOSTNAME; then
  echo "Multiple routes bound to the app but no SERVER_HOSTNAME variable is set."
  exit 1
fi

if [ -z "$SERVER_HOSTNAME" ]; then
  export SERVER_HOSTNAME=$HOSTNAME
fi

${LCSRV_HOME}/bin/license-server.sh configure \
		--listen 0.0.0.0 \
		--port 8111 \
		--jetty.virtualHosts.names=$HOSTNAME \
		--temp-dir ${LCSRV_HOME}/temp

exec /register.sh run &
exec ${LCSRV_HOME}/bin/license-server.sh run
