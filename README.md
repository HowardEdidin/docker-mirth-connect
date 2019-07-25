# Mirth Connect Docker

## Supported Tags

- 1.2.1, latest
- 1.2.0
- 1.1.1
- 1.1.0
- 1.0.0

## Description

The [mirth connect](https://www.nextgen.com/products-and-services/integration-engine)
docker is intended to allow for a stable way to run mirth within docker as
well as be configured appropriatly per environemt.

## Recommendations

It is best practice to not include sql user or password information in Dockerfiles. For that reason we have provided addtional environment variables
that can be added to a `docker-compose.override.yml` and injected via the [.env
or other such docker environment files](https://docs.docker.com/compose/env-file/).

# Environment Variables

##### MIRTH_CONFIG_FILE

The file path to a mirth configuration file. If the file exists it will be imported on container start.
An example may be `/data/mirth.config` mounted via a volume such as `-v ./data:/data`. Note that if this
environment variable is populated and the file does not exist no config will be imported and you will be informed that "no configuration file could be located"
even when the variable is not set.

##### MIRTH_SQL_SERVER_NAME

Specifies the name or ip address of the sql server to connect to.
Currently used in entrypoint to wait on the MSSQL server, will be expanded later
for mirth configurations.

##### MIRTH_CONNECT_VERSION

The version of mirth to use for the container. Check out [NextGen's archive](http://downloads.mirthcorp.com/archive/connect/) for available version.

##### MIRTH_TRANSFORM_PROPS

The boolean value of whether or not to transform the `mirth.properties`
file when the container starts; leaving the `mirth.properties` file untouched
after the container is run.

You may want to change `mirth.properties` when running the docker image
to reflect your desired settings and not use the `MIRTH_*` environement
variables.

When set to `true` `set_props` runs when the container starts which
substitutes various mirth properties with environment variables.

The default is set to false, but if you wish to transform the property file change this value to true. _The value is case sensative_.

##### MIRTH_DATABASE

Assigns to property `database` in `mirth.properties`. Available options are: `derby`, `mysql`, `postgres`, `oracle`, `sqlserver`.

##### MIRTH_DATABASE_URL

Assigns to property `database.url` in `mirth.properties`

```bash
# examples:
# Derby jdbc:derby:${dir.appdata}/mirthdb;create=true
# PostgreSQL jdbc:postgresql://localhost:5432/mirthdb
#  MySQL jdbc:mysql://localhost:3306/mirthdb
# Oracle jdbc:oracle:thin:@localhost:1521:DB
# SQLServer jdbc:jtds:sqlserver://localhost:1433/mirthdb
```

##### MIRTH_DATABASE_USERNAME

The username to login to any of the above sql servers with.

##### MIRTH_DATABASE_PASSWORD

The password to login to any of the above sql servers with.

##### MIRTH_ADMIN_PASSWORD

The initial administrator password when the container starts. When the
variable is set it will overrite the password each time the container
starts. When left blank the admin password _will not_ be modified.

## Considerations

The `Dockerfile` located at `mirth/Dockerfile` includes an installation of [`mssql-tools`](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-2017)
which are needed for our use case. The tools allow for `entrypoint.sh` to identify when the `mssql server`
is online, available, and if the `mirthdb` database has been created when using a separate
[mssql container](https://hub.docker.com/_/microsoft-mssql-server).
This is important as we cannot have `mirth-server-launcher` start before the sql server is online.
It is recommended to perform such a check even if you are using another external
database that is not `mssql server`  or at least `sleep 20s` before starting `mirth-server-launcher`.

The installed `mssql-tools` will not effect anything if you leave the environemt
variables to their defaults and will only run if `MIRTH_DATABSE` is set to `sqlserver`. __When `sqlserver` is specified the mirth will not prompt for
the registration of users or show notifications on startup.
