#!/bin/sh
if [ -z "$JETBRAINS_USERNAME" ] || [ -z "$JETBRAINS_PASSWORD" ] || [ -z "$SERVER_NAME" ]; then
  echo "Error: Please provide JETBRAINS_USERNAME, JETBRAINS_PASSWORD and SERVER_NAME"
  exit 1
fi

REGISTRATION_HOSTNAME=$HOSTNAME # comes from entrypoint.sh

if [ ! -z $(echo "$REGISTRATION_HOSTNAME" | grep ,) ]; then
  if [ -z "$SERVER_HOSTNAME" ]; then
    echo "Error: Server started with multiple routes ($REGISTRATION_HOSTNAME), but no SERVER_HOSTNAME was configured for registration"
    exit 1
  else
    echo "Using $SERVER_HOSTNAME for authentication"
    REGISTRATION_HOSTNAME=$SERVER_HOSTNAME
  fi
fi

sleep $SLEEPING # wait until the license server is up

echo "Trying to register https://$REGISTRATION_HOSTNAME with $JETBRAINS_USERNAME as $SERVER_NAME"
if [ ! -z "$SERVER_USERNAME" ] && [ ! -z "$SERVER_PASSWORD" ]; then
  echo "Using authentication"
  exec $LCSRV_HOME/register "https://$SERVER_USERNAME:$SERVER_PASSWORD@$REGISTRATION_HOSTNAME/register" "$JETBRAINS_USERNAME" "$JETBRAINS_PASSWORD" "$SERVER_NAME"
else
  exec $LCSRV_HOME/register "https://$REGISTRATION_HOSTNAME/register" "$JETBRAINS_USERNAME" "$JETBRAINS_PASSWORD" "$SERVER_NAME"
fi
