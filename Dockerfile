############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################
# latest version uo to 2017-02-02
FROM phusion/baseimage:0.9.19
MAINTAINER AquaBiota Solutions AB <info@aquabiota.se>
# Use baseimage-docker's init system.
# See: [Adding additional daemons](http://phusion.github.io/baseimage-docker/#solution)
# https://github.com/phusion/baseimage-docker#adding-additional-daemons

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-8-oracle

ARG ORIENTDB_DOWNLOAD_SERVER
ENV ORIENTDB_VERSION 2.2.16
ENV ORIENTDB_DOWNLOAD_MD5 dbfda032e428ff074a9ed0b40db06e74
ENV ORIENTDB_DOWNLOAD_SHA1 0e0e0fea7060bfd3c36db194d7d5cab5b10cb949

ENV ORIENTDB_DOWNLOAD_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz


RUN apt-get update && \
    apt-get -yq upgrade && \
    apt-get -yq install \
    python-software-properties \
    software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -yq install oracle-java8-installer && \
    update-alternatives --display java && \
    apt-get -yq install oracle-java8-set-default && \
    mkdir -p /etc/service/orientdb/run && \
    mkdir -p /etc/service/orientdb/supervise

# download distribution tar, untar and delete databases
# http://mkt.orientdb.com/CE-2215-linux/
RUN mkdir /orientdb && \
  # #http://orientdb.com/download.php?email=unknown@unknown.com\&file=orientdb-community-$ORIENTDB_VERSION.tar.gz\&os=linux -O /tmp/orientdb-community-$ORIENTDB_VERSION.tar.gz && \
  wget $ORIENTDB_DOWNLOAD_URL \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  # strip NUMBER leading components from file names on extraction
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1 \
  && rm orientdb-community-$ORIENTDB_VERSION.tar.gz \
  # Removing databases
  && rm -rf /orientdb/databases/* \

ENV PATH /orientdb/bin:$PATH

VOLUME ["/orientdb/backup", "/orientdb/databases", "/orientdb/config"]

WORKDIR /orientdb

#OrientDb binary
EXPOSE 2424

#OrientDb http
EXPOSE 2480

############################################################
# Dockerfile  for OrientDB with spatial module and neo4j connector
############################################################

#FROM orientdb:2.2.15

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 41a5b88b6bcea73e6037732ed6977c39
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 937ed8c4990bd1ac27534449a8517a3ac7999a80

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-$ORIENTDB_VERSION-dist.jar /orientdb/lib/


# Clean up APT when done.
RUN apt-get -yq clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# see: https://github.com/phusion/baseimage-docker#adding-additional-daemons
# see: https://github.com/broadinstitute/docker-orientdb/blob/master/run.sh
ADD run.sh /etc/service/orientdb/run

# the file needs to be executable
RUN chmod 755 /etc/service/orientdb/run
# Default command start the server
# Is commented as we are using the
#CMD ["server.sh", "dserver.sh"]
