#!/bin/sh
if [ ! -z "$USER" ] && [ ! -z "$PASSWORD" ] && [ ! -z "$SERVER_NAME" ]
then
  sleep 30
  echo "Trying to register https://$HOSTNAME with $USER as $SERVER_NAME"
  exec $LCSRV_HOME/register "https://$HOSTNAME" "$USER" "$PASSWORD" "$SERVER_NAME"
fi
