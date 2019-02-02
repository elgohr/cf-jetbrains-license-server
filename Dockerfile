FROM alpine as alpinejq
RUN apk add --no-cache jq

FROM alpinejq as startupTest
ENV USER_HOME /home/jetbrains
ADD entrypoint.sh entrypoint_test.sh ${USER_HOME}/
ADD mock.sh ${USER_HOME}/license-server/bin/license-server.sh
ADD mock.sh ${USER_HOME}/register.sh
RUN chmod +x ${USER_HOME}/license-server/bin/license-server.sh \
  && chmod +x ${USER_HOME}/register.sh \
  && ${USER_HOME}/entrypoint_test.sh

FROM alpine as registerTest
ENV USER_HOME /home/jetbrains
ADD register.sh register_test.sh ${USER_HOME}/
ADD mock.sh ${USER_HOME}/register
RUN chmod +x ${USER_HOME}/register \
  && ${USER_HOME}/register_test.sh

FROM golang:1.11-alpine as goDep
RUN apk add --no-cache \
 git \
 && go get -u github.com/golang/dep/cmd/dep

FROM goDep as build
WORKDIR /go/src/github.com/elgohr/cf-jetbrains-license-server
ADD register.go register_test.go Gopkg.toml Gopkg.toml ./
ADD testdata/* ./testdata/
RUN dep ensure \
 && go test -v \
 && go build register.go \
 && chmod +x ./register

FROM java:8-jre-alpine as runtime
ENV USER_HOME /home/jetbrains
COPY --from=build /go/src/github.com/elgohr/cf-jetbrains-license-server/register ${USER_HOME}/
ADD entrypoint.sh register.sh ${USER_HOME}/
RUN apk add --no-cache \
 ca-certificates \
 wget \
 openssl \
 jq \
 && adduser -S jetbrains \
 && wget -q https://download.jetbrains.com/lcsrv/license-server-installer.zip \
 && mkdir -p ${USER_HOME}/license-server \
 && unzip -q license-server-installer.zip -d ${USER_HOME}/license-server \
 && chown -R jetbrains ${USER_HOME}/license-server \
 && rm -f license-server-installer.zip
USER jetbrains
EXPOSE 8111
WORKDIR $USER_HOME
ENTRYPOINT ["/bin/sh", "/home/jetbrains/entrypoint.sh"]
