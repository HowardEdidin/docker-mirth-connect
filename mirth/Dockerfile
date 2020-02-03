FROM ubuntu:16.04

LABEL author="Howard Edidin"
LABEL maintainter="The Core Dev Team"



# Container specific properties
ENV MIRTH_CONNECT_VERSION 3.8.0.b2464
ENV MIRTH_TRANSFORM_PROPS true
# admin is the default mirth password
# http://www.mirthcorp.com/community/wiki/display/mirthuserguidev1r8p0/Login
ENV MIRTH_ADMIN_PASSWORD ''
# Default settings for mirth database
# Configure here or in .env file for docker compose.
# https://docs.docker.com/compose/env-file/
# mirht.properties props are set in set_props.java
ENV MIRTH_SQL_SERVER_NAME ''
ENV MIRTH_DATABASE sqlserver
ENV MIRTH_DATABASE_URL jdbc:jtds:sqlserver://localhost:1433/mirthdb
ENV MIRTH_DATABASE_USERNAME sa
ENV MIRTH_DATABASE_PASSWORD Suyo1054
ENV MIRTH_CONFIG_FILE ''

#------ Install open jdk and extract mirth ------#

RUN apt-get update \
    && apt-get install -y openjdk-8-jdk curl

RUN useradd -u 1000 mirth
RUN curl http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz \
    | tar xz -C /opt \
    && mv -f /opt/Mirth\ Connect /opt/mirth-connect \
    && chown -R mirth /opt/mirth-connect

ENV MIRTH_PROP_FILE /opt/mirth-connect/conf/mirth.properties
COPY mirth.properties ${MIRTH_PROP_FILE}

#------ Install mssql server and set path ------#
# https://github.com/Microsoft/mssql-docker/blob/master/linux/mssql-tools/Dockerfile

RUN apt-get update \
    && apt-get install -y apt-transport-https debconf-utils \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list \
    | tee /etc/apt/sources.list.d/msprod.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools msodbcsql

RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN apt-get -y install netcat

#------ Set up container specifics ------#

COPY init.sql /app/
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

WORKDIR /opt/mirth-connect

COPY set_props.java ./

RUN javac set_props.java \
    && rm set_props.java

EXPOSE 8080 8443

ENTRYPOINT [ "/app/entrypoint.sh" ]
