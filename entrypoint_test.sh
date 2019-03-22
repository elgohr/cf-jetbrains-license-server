#!/bin/sh -e

function clean() {
  unset VCAP_APPLICATION
  unset HTTP_PROXYHOST
  unset HTTP_PROXYPORT
  unset HTTP_PROXYUSER
  unset HTTP_PROXYPASSWORD
  unset HTTPS_PROXYHOST
  unset HTTPS_PROXYPORT
  unset HTTPS_PROXYUSER
  unset HTTPS_PROXYPASSWORD
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

function itCommunicatesViaHttpProxyIfProvided() {
  clean
  export HTTP_PROXYHOST='http://myCompany.proxy'
  export HTTP_PROXYPORT='8080'
  export VCAP_APPLICATION='{"someOtherArray":["somethingElse"],"application_uris":["myfirst.route","mysecond.route"],"uris":["not.this.route","not.this.route2"]}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir /home/jetbrains/license-server/temp -J-Dhttp.proxyHost http://myCompany.proxy -J-Dhttp.proxyPort 8080
Called mock with: run
Called mock with: run" ]; then
    echo "Didn't use the http proxy server: $result"
    exit 1
  fi
}

function itCommunicatesViaSecuredHttpProxyIfProvided() {
  clean
  export HTTP_PROXYUSER='myUser'
  export HTTP_PROXYPASSWORD='myPassword'
  export HTTP_PROXYHOST='http://myCompany.proxy'
  export HTTP_PROXYPORT='8080'
  export VCAP_APPLICATION='{"someOtherArray":["somethingElse"],"application_uris":["myfirst.route","mysecond.route"],"uris":["not.this.route","not.this.route2"]}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir /home/jetbrains/license-server/temp -J-Dhttp.proxyHost http://myCompany.proxy -J-Dhttp.proxyPort 8080 -J-Dhttp.proxyUser myUser -J-Dhttp.proxyPassword myPassword
Called mock with: run
Called mock with: run" ]; then
    echo "Didn't use the secured http proxy server: $result"
    exit 1
  fi
}

function itCommunicatesViaHttpsProxyIfProvided() {
  clean
  export HTTPS_PROXYHOST='https://myCompanys.proxy'
  export HTTPS_PROXYPORT='8443'
  export VCAP_APPLICATION='{"someOtherArray":["somethingElse"],"application_uris":["myfirst.route","mysecond.route"],"uris":["not.this.route","not.this.route2"]}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir /home/jetbrains/license-server/temp -J-Dhttps.proxyHost https://myCompanys.proxy -J-Dhttps.proxyPort 8443
Called mock with: run
Called mock with: run" ]; then
    echo "Didn't use the https proxy server: $result"
    exit 1
  fi
}

function itCommunicatesViaSecuredHttpsProxyIfProvided() {
  clean
  export HTTPS_PROXYUSER='myUser'
  export HTTPS_PROXYPASSWORD='myPassword'
  export HTTPS_PROXYHOST='https://myCompanys.proxy'
  export HTTPS_PROXYPORT='8443'
  export VCAP_APPLICATION='{"someOtherArray":["somethingElse"],"application_uris":["myfirst.route","mysecond.route"],"uris":["not.this.route","not.this.route2"]}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir /home/jetbrains/license-server/temp -J-Dhttps.proxyHost https://myCompanys.proxy -J-Dhttps.proxyPort 8443 -J-Dhttps.proxyUser myUser -J-Dhttps.proxyPassword myPassword
Called mock with: run
Called mock with: run" ]; then
    echo "Didn't use the secured https proxy server: $result"
    exit 1
  fi
}

function itAddsCustomOptionsApplicationUris() {
  clean
  export CUSTOM_OPTIONS='THIS_IS_CUSTOM'
  export VCAP_APPLICATION='{"someOtherArray":["somethingElse"],"application_uris":["myfirst.route","mysecond.route"],"uris":["not.this.route","not.this.route2"]}'
  result=$(exec ${USER_HOME}/entrypoint.sh)
  if [ "$result" != "Called mock with: configure --listen 0.0.0.0 --port 8111 --jetty.virtualHosts.names=myfirst.route,mysecond.route --temp-dir /home/jetbrains/license-server/temp THIS_IS_CUSTOM
Called mock with: run
Called mock with: run" ]; then
    echo "Didn't add custom options: $result"
    exit 1
  fi
}

itStartsUpTheServerWithOneRoute
itStartsUpTheServerWithMultipleRoutes
itUsesApplicationUris
itCommunicatesViaHttpProxyIfProvided
itCommunicatesViaHttpsProxyIfProvided
itCommunicatesViaSecuredHttpProxyIfProvided
itCommunicatesViaSecuredHttpsProxyIfProvided
itAddsCustomOptionsApplicationUris
