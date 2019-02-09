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

echo "Trying to register http://localhost:8111/register with $JETBRAINS_USERNAME as $SERVER_NAME"
exec $USER_HOME/register "http://localhost:8111/register" "$JETBRAINS_USERNAME" "$JETBRAINS_PASSWORD" "$SERVER_NAME"

