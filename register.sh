#!/bin/sh
if [ ! -z "$JETBRAINS_USERNAME" ] && [ ! -z "$JETBRAINS_PASSWORD" ] && [ ! -z "$SERVER_NAME" ]
then
  sleep 30
  echo "Trying to register https://$HOSTNAME with $JETBRAINS_USERNAME as $SERVER_NAME"
  if [ ! -z "$SERVER_USERNAME" ] && [ ! -z "$SERVER_PASSWORD" ]
  then
    echo "Using authentication"
    exec $LCSRV_HOME/register "https://$SERVER_USERNAME:$SERVER_PASSWORD@$HOSTNAME/register" "$JETBRAINS_USERNAME" "$JETBRAINS_PASSWORD" "$SERVER_NAME"
  else
    exec $LCSRV_HOME/register "https://$HOSTNAME/register" "$JETBRAINS_USERNAME" "$JETBRAINS_PASSWORD" "$SERVER_NAME"
  fi
fi
