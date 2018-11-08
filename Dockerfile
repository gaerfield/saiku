FROM openjdk:8-jre

ARG SAIKU_DOWNLOAD_URL=https://www.meteorite.bi/downloads/saiku-latest.zip

ENV DEBIAN_FRONTEND noninteractive
ENV SAIKU_HOME=/saiku
ENV INSTANCEDIR_BOOTSTRAP=/saiku-bootstrap
ENV INSTANCEDIR=$SAIKU_HOME/data
ENV ADDITIONAL_CUBES=/additionalCubes

RUN  apt-get update \
  && apt-get install -y \
     curl \
     zip \
  && rm -rf /var/lib/apt/lists/*

RUN  curl -Lsf -o /tmp/saiku.zip $SAIKU_DOWNLOAD_URL \
  && unzip /tmp/saiku.zip -d /tmp/ \
  && mv /tmp/saiku-server $SAIKU_HOME \
  && rm /tmp/saiku.zip \
  && mv $INSTANCEDIR $INSTANCEDIR_BOOTSTRAP \
  && mkdir $INSTANCEDIR \
  && mkdir $ADDITIONAL_CUBES

EXPOSE 8080
VOLUME ["$INSTANCEDIR"]
COPY ./docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
CMD ["docker-entrypoint.sh"]
