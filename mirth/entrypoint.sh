#!/bin/bash
if [[ $MIRTH_DATABASE = sqlserver ]]
then
    code=1
    while [ $code != 0 ]
    do
        sqlcmd -S med-route-mssql -U sa \
            -P $MIRTH_DATABASE_PASSWORD -Q "SELECT GETDATE()" \
            >> /dev/null
        code=$?
        echo waiting for connection
        sleep 1s
    done

    result="$(sqlcmd -S med-route-mssql -U sa -P $MIRTH_DATABASE_PASSWORD \
            -Q "SELECT DB_ID('mirthdb')" -h-1 | grep NULL | xargs)"

    if [[ $result = NULL ]]
    then
        sqlcmd -S med-route-mssql -U sa -P $MIRTH_DATABASE_PASSWORD \
            -Q "CREATE DATABASE mirthdb;"
    fi
fi

if [[ $MIRTH_TRANSFORM_PROPS = true ]]
then
    java /app/set_props $MIRTH_PROP_FILE
fi

java -jar mirth-server-launcher.jar