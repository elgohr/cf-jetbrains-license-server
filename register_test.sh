#!/bin/sh

function clean() {
  unset JETBRAINS_USERNAME
  unset JETBRAINS_PASSWORD
  unset SERVER_NAME
  unset SERVER_USERNAME
  unset SERVER_PASSWORD
  unset SERVER_HOSTNAME
}

function itErrorsWhenJETBRAINS_USERNAMEisNotProvided() {
  clean
  export JETBRAINS_PASSWORD="IsSet"
  export SERVER_NAME="IsSet"
  result=$(exec ./register.sh)
  if [ -z "$result" ]; then
    echo "Does not fail with missing JETBRAINS_USERNAME"
    exit 1
  fi
}

function itErrorsWhenJETBRAINS_PASSWORDisNotProvided() {
  clean
  export JETBRAINS_USERNAME="IsSet"
  export SERVER_NAME="IsSet"
  result=$(exec ./register.sh)
  if [ -z "$result" ]; then
    echo "Does not fail with missing JETBRAINS_PASSWORD"
    exit 1
  fi
}

function itErrorsWhenSERVER_NAMEisNotProvided() {
  clean
  export JETBRAINS_USERNAME="IsSet"
  export JETBRAINS_PASSWORD="IsSet"
  result=$(exec ./register.sh)
  if [ -z "$result" ]; then
    echo "Does not fail with missing SERVER_NAME"
    exit 1
  fi
}

function itCallsTheRegistrationScript() {
  clean
  export HOSTNAME="host.name" # set by entrypoint.
  export JETBRAINS_USERNAME="USER"
  export JETBRAINS_PASSWORD="PASSWORD"
  export SERVER_NAME="SERVER_NAME"
  result=$(exec ./register.sh)
  if [ "$result" != "Trying to register https://$HOSTNAME with $JETBRAINS_USERNAME as $SERVER_NAME
Called mock with: https://$HOSTNAME/register $JETBRAINS_USERNAME $JETBRAINS_PASSWORD $SERVER_NAME" ]; then
    echo "Registration mock was not called as expected: $result"
    exit 1
  fi
}

function itCallsTheRegistrationScriptWithPasswordIfProvided() {
  clean
  export HOSTNAME="host.name" # set by entrypoint.
  export JETBRAINS_USERNAME="USER"
  export JETBRAINS_PASSWORD="PASSWORD"
  export SERVER_NAME="SERVER_NAME"
  export SERVER_USERNAME="SERVER_USERNAME"
  export SERVER_PASSWORD="SERVER_PASSWORD"
  result=$(exec ./register.sh)
  if [ "$result" != "Trying to register https://$HOSTNAME with $JETBRAINS_USERNAME as $SERVER_NAME
Using authentication
Called mock with: https://$SERVER_USERNAME:$SERVER_PASSWORD@$HOSTNAME/register $JETBRAINS_USERNAME $JETBRAINS_PASSWORD $SERVER_NAME" ]; then
    echo "Registration mock was not called as expected: $result"
    exit 1
  fi
}

function itErrorsWhenMultipleRoutesAreSetButNoSERVER_HOSTNAMEwasSpecified() {
  clean
  export HOSTNAME="myfirst.route,mysecond.route" # set by entrypoint.
  export JETBRAINS_USERNAME="USER"
  export JETBRAINS_PASSWORD="PASSWORD"
  export SERVER_NAME="SERVER_NAME"
  export SERVER_USERNAME="SERVER_USERNAME"
  export SERVER_PASSWORD="SERVER_PASSWORD"
  result=$(exec ./register.sh)
  if [ "$result" != "Error: Server started with multiple routes ($HOSTNAME), but no SERVER_HOSTNAME was configured for registration" ]; then
    echo "Does not fail with missing SERVER_HOSTNAME: $result"
    exit 1
  fi
}

function itUsesSERVER_HOSTNAMEwhenSetWithoutAuthentication() {
  clean
  export HOSTNAME="myfirst.route,mysecond.route" # set by entrypoint.
  export JETBRAINS_USERNAME="USER"
  export JETBRAINS_PASSWORD="PASSWORD"
  export SERVER_NAME="SERVER_NAME"
  export SERVER_HOSTNAME="SERVER_HOSTNAME"
  result=$(exec ./register.sh)
  if [ "$result" != "Using $SERVER_HOSTNAME for authentication
Trying to register https://$SERVER_HOSTNAME with $JETBRAINS_USERNAME as $SERVER_NAME
Called mock with: https://$SERVER_HOSTNAME/register $JETBRAINS_USERNAME $JETBRAINS_PASSWORD $SERVER_NAME" ]; then
    echo "Does not use SERVER_HOSTNAME: $result"
    exit 1
  fi
}

function itUsesSERVER_HOSTNAMEwhenSetWithAuthentication() {
  clean
  export HOSTNAME="myfirst.route,mysecond.route" # set by entrypoint.
  export JETBRAINS_USERNAME="USER"
  export JETBRAINS_PASSWORD="PASSWORD"
  export SERVER_NAME="SERVER_NAME"
  export SERVER_HOSTNAME="SERVER_HOSTNAME"
  export SERVER_USERNAME="SERVER_USERNAME"
  export SERVER_PASSWORD="SERVER_PASSWORD"
  result=$(exec ./register.sh)
  if [ "$result" != "Using $SERVER_HOSTNAME for authentication
Trying to register https://$SERVER_HOSTNAME with $JETBRAINS_USERNAME as $SERVER_NAME
Using authentication
Called mock with: https://$SERVER_USERNAME:$SERVER_PASSWORD@$SERVER_HOSTNAME/register $JETBRAINS_USERNAME $JETBRAINS_PASSWORD $SERVER_NAME" ]; then
    echo "Does not use SERVER_HOSTNAME with authentication: $result"
    exit 1
  fi
}

itErrorsWhenJETBRAINS_USERNAMEisNotProvided
itErrorsWhenJETBRAINS_PASSWORDisNotProvided
itErrorsWhenSERVER_NAMEisNotProvided
itCallsTheRegistrationScript
itCallsTheRegistrationScriptWithPasswordIfProvided
itErrorsWhenMultipleRoutesAreSetButNoSERVER_HOSTNAMEwasSpecified
itUsesSERVER_HOSTNAMEwhenSetWithoutAuthentication
itUsesSERVER_HOSTNAMEwhenSetWithAuthentication
