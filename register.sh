#!/bin/sh
if [ -z "$JETBRAINS_USERNAME" ] || [ -z "$JETBRAINS_PASSWORD" ] || [ -z "$SERVER_NAME" ]; then
  echo "Error: Please provide JETBRAINS_USERNAME, JETBRAINS_PASSWORD and SERVER_NAME"
  exit 1
fi

echo "Trying to register http://localhost:8111/register with $JETBRAINS_USERNAME as $SERVER_NAME"
exec $USER_HOME/register "http://localhost:8111/register" "$JETBRAINS_USERNAME" "$JETBRAINS_PASSWORD" "$SERVER_NAME"
