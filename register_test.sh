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
  result=$(exec ${USER_HOME}/register.sh)
  if [ -z "$result" ]; then
    echo "Does not fail with missing JETBRAINS_USERNAME"
    exit 1
  fi
}

function itErrorsWhenJETBRAINS_PASSWORDisNotProvided() {
  clean
  export JETBRAINS_USERNAME="IsSet"
  export SERVER_NAME="IsSet"
  result=$(exec ${USER_HOME}/register.sh)
  if [ -z "$result" ]; then
    echo "Does not fail with missing JETBRAINS_PASSWORD"
    exit 1
  fi
}

function itErrorsWhenSERVER_NAMEisNotProvided() {
  clean
  export JETBRAINS_USERNAME="IsSet"
  export JETBRAINS_PASSWORD="IsSet"
  result=$(exec ${USER_HOME}/register.sh)
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
  result=$(exec ${USER_HOME}/register.sh)
  if [ "$result" != "Trying to register http://localhost:8111/register with $JETBRAINS_USERNAME as $SERVER_NAME
Called mock with: http://localhost:8111/register $JETBRAINS_USERNAME $JETBRAINS_PASSWORD $SERVER_NAME" ]; then
    echo "Registration mock was not called as expected: $result"
    exit 1
  fi
}

itErrorsWhenJETBRAINS_USERNAMEisNotProvided
itErrorsWhenJETBRAINS_PASSWORDisNotProvided
itErrorsWhenSERVER_NAMEisNotProvided
itCallsTheRegistrationScript
