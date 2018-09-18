#!/bin/sh

function itStartsUpTheServerWithOneRoute() {
  export VCAP_APPLICATION='{uris:["myfirst.route"]}'
  result=$(exec ./entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route --temp-dir //temp
Called mock with: run
Called mock with: run" ]; then
    echo "Does not start up the server as expected: $result"
    exit 1
  fi
}

function itStartsUpTheServerWithMultipleRoutes() {
  export VCAP_APPLICATION='{uris:["myfirst.route","mysecond.route"]}'
  result=$(exec ./entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir //temp
Called mock with: run
Called mock with: run" ]; then
    echo "Does not start up the server as expected: $result"
    exit 1
  fi
}

itStartsUpTheServerWithOneRoute
itStartsUpTheServerWithMultipleRoutes
