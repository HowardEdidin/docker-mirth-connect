#!/bin/bash
if [[ $MIRTH_DATABASE = sqlserver ]]
then
    code=1
    while [ $code != 0 ]
    do
        /opt/mssql-tools/bin/sqlcmd -S $SQL_SERVER -U sa \
            -P $MIRTH_DATABASE_PASSWORD -Q "SELECT GETDATE()" \
            >> /dev/null
        code=$?
        echo waiting for connection
        sleep 1s
    done

    result="$(/opt/mssql-tools/bin/sqlcmd -S $SQL_SERVER -U sa -P $MIRTH_DATABASE_PASSWORD \
            -Q "SELECT DB_ID('mirthdb')" -h-1 | grep NULL | xargs)"

    if [[ $result = NULL ]]
    then
        /opt/mssql-tools/bin/sqlcmd -S $SQL_SERVER -U sa -P $MIRTH_DATABASE_PASSWORD \
            -Q "CREATE DATABASE mirthdb;"
    fi
fi

if [[ $MIRTH_TRANSFORM_PROPS = true ]]
then
    java set_props $MIRTH_PROP_FILE
fi

java -jar mirth-server-launcher.jar