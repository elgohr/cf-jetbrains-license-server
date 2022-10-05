FROM alpine:3.16.2 as alpinejq
ARG JETBRAINS_USERNAME
ARG JETBRAINS_PASSWORD
RUN apk add --no-cache jq

FROM alpinejq as startupTest
ARG JETBRAINS_USERNAME
ARG JETBRAINS_PASSWORD
ENV USER_HOME /home/jetbrains
ADD entrypoint.sh entrypoint_test.sh ${USER_HOME}/
ADD mock.sh ${USER_HOME}/license-server/bin/license-server.sh
ADD mock.sh ${USER_HOME}/register.sh
RUN chmod +x ${USER_HOME}/license-server/bin/license-server.sh \
  && chmod +x ${USER_HOME}/register.sh \
  && ${USER_HOME}/entrypoint_test.sh

FROM alpine:3.16.2 as registerTest
ARG JETBRAINS_USERNAME
ARG JETBRAINS_PASSWORD
ENV USER_HOME /home/jetbrains
ADD register.sh register_test.sh ${USER_HOME}/
ADD mock.sh ${USER_HOME}/register
RUN chmod +x ${USER_HOME}/register \
  && ${USER_HOME}/register_test.sh

FROM golang:1.19.2 as build
ARG JETBRAINS_USERNAME
ARG JETBRAINS_PASSWORD
WORKDIR /cf-jetbrains-license-server
ADD register.go register_test.go go.mod go.sum ./
ADD testdata/* ./testdata/
ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
RUN go test -v \
 && go build register.go \
 && chmod +x register

FROM openjdk:19-alpine3.15 as runtime
ARG JETBRAINS_USERNAME
ARG JETBRAINS_PASSWORD
ENV USER_HOME /home/jetbrains
COPY --from=build /cf-jetbrains-license-server/register ${USER_HOME}/
ENV PATH=$PATH:/opt/jdk/bin
ADD entrypoint.sh register.sh ${USER_HOME}/
RUN apk update && apk upgrade && \
apk add --no-cache \
 ca-certificates \
 wget \
 openssl \
 jq \
 && adduser -S -D jetbrains \
 && wget -q https://download.jetbrains.com/lcsrv/license-server-installer.zip \
 && mkdir -p ${USER_HOME}/license-server \
 && unzip -q license-server-installer.zip -d ${USER_HOME}/license-server \
 && chown -R jetbrains ${USER_HOME}/license-server \
 && rm -f license-server-installer.zip
USER jetbrains
EXPOSE 8111
WORKDIR $USER_HOME
ENTRYPOINT ["/bin/sh", "/home/jetbrains/entrypoint.sh"]

FROM runtime as integrationTest
ARG JETBRAINS_USERNAME
ARG JETBRAINS_PASSWORD
ENV VCAP_APPLICATION '{"application_uris":["localhost"]}'
ENV SERVER_NAME 'License Server'
ADD integration_test.sh /
RUN /integration_test.sh

FROM runtime
