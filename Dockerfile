FROM alpine as alpinejq
RUN apk add --no-cache jq

FROM alpinejq as startupTest
ADD entrypoint.sh entrypoint_test.sh /
ADD mock.sh /bin/license-server.sh
ADD mock.sh /register.sh
ENV LCSRV_HOME /

RUN chmod +x /bin/license-server.sh \
  && chmod +x /register.sh \
  && ./entrypoint_test.sh

FROM alpine as registerTest
ADD register.sh register_test.sh /
ADD mock.sh ./register
ENV LCSRV_HOME /

RUN chmod +x ./register \
  && ./register_test.sh

FROM golang:1.10-alpine as goDep

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

ENV LCSRV_HOME /usr/bin/jetbrains/license-server
COPY --from=build /go/src/github.com/elgohr/cf-jetbrains-license-server/register $LCSRV_HOME/

RUN apk add --no-cache \
 ca-certificates \
 wget \
 openssl \
 jq \
 && wget -q https://download.jetbrains.com/lcsrv/license-server-installer.zip \
 && mkdir -p $LCSRV_HOME \
 && unzip license-server-installer.zip -d $LCSRV_HOME \
 && rm -f license-server-installer.zip

ADD entrypoint.sh register.sh /

EXPOSE 8111

WORKDIR $LCSRV_HOME

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
