############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################
FROM phusion/baseimage:0.9.19 # latest version uo to 2017-02-02
MAINTAINER José Beltrán <jose.beltran@aquabiota.se>
# Use baseimage-docker's init system.
# See: [Adding additional daemons](http://phusion.github.io/baseimage-docker/#solution)
# https://github.com/phusion/baseimage-docker#adding-additional-daemons

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-8-oracle

ARG ORIENTDB_DOWNLOAD_SERVER
ENV ORIENTDB_VERSION 2.2.15
ENV ORIENTDB_DOWNLOAD_MD5 ef6fdd215f17ef5df756b85c9ea09755
ENV ORIENTDB_DOWNLOAD_SHA1 80f26162d5f7545591d6c29ecf4845d314190060
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
    mkdir -p /etc/service/orientdb/supervise && \


# download distribution tar, untar and delete databases
RUN mkdir /orientdb && \
  wget  $ORIENTDB_DOWNLOAD_URL \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1 \
  && rm orientdb-community-$ORIENTDB_VERSION.tar.gz \
  && rm -rf /orientdb/databases/*


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

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 8cb548237b17bc180b08ba3a465cb9ef
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 a9e5b2ea6ebd082acb915674085b10cffcc5a8b4

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/


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
