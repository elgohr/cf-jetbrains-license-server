FROM java:8-jre
MAINTAINER Lars Gohr <larsgohr@gmail.com>

ENV LCSRV_HOME /usr/bin/jetbrains/license-server
ENV ACCESS_CONFIG_URL https://raw.githubusercontent.com/elgohr/cf-jetbrains-license-server/master/access-config.json

RUN wget https://download.jetbrains.com/lcsrv/license-server-installer.zip \
 && mkdir -p $LCSRV_HOME \
 && unzip license-server-installer.zip -d $LCSRV_HOME \
 && wget -O $LCSRV_HOME/access-config.json $ACCESS_CONFIG_URL

ADD ./entrypoint.sh /entrypoint.sh

EXPOSE 8111

VOLUME $LCSRV_HOME
WORKDIR $LCSRV_HOME

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
