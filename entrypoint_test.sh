#!/bin/sh

function clean() {
  unset VCAP_APPLICATION
}

function itStartsUpTheServerWithOneRoute() {
  clean
  export VCAP_APPLICATION='{"instance_id":"fe98dc76ba549876543210abcd1234","instance_index":0,"host":"0.0.0.0","port":61857,"started_at":"2013-08-1200:05:29 +0000","started_at_timestamp":1376265929,"start":"2013-08-12 00:05:29+0000","state_timestamp":1376265929,"limits":{"mem":512,"disk":1024,"fds":16384},"application_version":"ab12cd34-5678-abcd-0123-abcdef987654","application_name":"jb-testserver","application_uris":["myfirst.route"],"version":"ab12cd34-5678-abcd-0123-abcdef987654","name":"my-app","uris":["myfirst.route"],"users":null}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route --temp-dir /home/jetbrains/license-server/temp
Called mock with: run
Called mock with: run" ]; then
    echo "Does not start up the server as expected: $result"
    exit 1
  fi
}

function itStartsUpTheServerWithMultipleRoutes() {
  clean
  export VCAP_APPLICATION='{"instance_id":"fe98dc76ba549876543210abcd1234","instance_index":0,"host":"0.0.0.0","port":61857,"started_at":"2013-08-1200:05:29 +0000","started_at_timestamp":1376265929,"start":"2013-08-12 00:05:29+0000","state_timestamp":1376265929,"limits":{"mem":512,"disk":1024,"fds":16384},"application_version":"ab12cd34-5678-abcd-0123-abcdef987654","application_name":"jb-testserver","application_uris":["myfirst.route","mysecond.route"],"version":"ab12cd34-5678-abcd-0123-abcdef987654","name":"my-app","uris":["myfirst.route","mysecond.route"],"users":null}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir /home/jetbrains/license-server/temp
Called mock with: run
Called mock with: run" ]; then
    echo "Does not start up the server as expected: $result"
    exit 1
  fi
}

function itUsesApplicationUris() {
  clean
  export VCAP_APPLICATION='{"someOtherArray":["somethingElse"],"application_uris":["myfirst.route","mysecond.route"],"uris":["not.this.route","not.this.route2"]}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir /home/jetbrains/license-server/temp
Called mock with: run
Called mock with: run" ]; then
    echo "Didn't use the application_uris: $result"
    exit 1
  fi
}

itStartsUpTheServerWithOneRoute
itStartsUpTheServerWithMultipleRoutes
itUsesApplicationUris
