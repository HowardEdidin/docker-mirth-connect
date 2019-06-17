FROM ubuntu:16.04

LABEL author="Mark Pro"
LABEL maintainter="StratusCube Core Dev Team"
LABEL company="StratusCube LLC"

ENV SQL_SERVER ''

# Container specific properties
ENV MIRTH_CONNECT_VERSION 3.7.1.b243
ENV MIRTH_TRANSFORM_PROPS false

# Default settings for mirth database
# Configure here or in .env file for docker compose.
# https://docs.docker.com/compose/env-file/
# mirht.properties props are set in set_props.java
ENV MIRTH_DATABASE derby
ENV MIRTH_DATABASE_URL jdbc:derby:appdata/mirthdb;create=true
ENV MIRTH_DATABASE_USERNAME ''
ENV MIRTH_DATABASE_PASSWORD ''


# admin is the default mirth password
# http://www.mirthcorp.com/community/wiki/display/mirthuserguidev1r8p0/Login
ENV MIRTH_ADMIN_PASSWORD admin

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

#------ Set up container specifics ------#

COPY entrypoint.sh set_props.java /app/
RUN chmod +x /app/entrypoint.sh

RUN javac /app/set_props.java -d /app \
    && rm /app/set_props.java

WORKDIR /opt/mirth-connect

EXPOSE 8080 8443

ENTRYPOINT [ "/app/entrypoint.sh" ]