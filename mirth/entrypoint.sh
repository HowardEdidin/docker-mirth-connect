#!/bin/bash
[[ "$MIRTH_DATABASE" == "sqlserver" ]] && isSqlServer=true || isSqlServer=false
if $isSqlServer ;
then
    code=1
    while [ $code != 0 ]
    do
        /opt/mssql-tools/bin/sqlcmd -S $MIRTH_SQL_SERVER_NAME -U sa \
            -P $MIRTH_DATABASE_PASSWORD -Q "SELECT GETDATE()" \
            >> /dev/null
        code=$?
        echo waiting for connection
        sleep 1s
    done

    result="$(/opt/mssql-tools/bin/sqlcmd -S $MIRTH_SQL_SERVER_NAME -U sa -P $MIRTH_DATABASE_PASSWORD \
            -Q "SELECT DB_ID('mirthdb')" -h-1 | grep NULL | xargs)"

    if [[ $result = NULL ]]
    then
        /opt/mssql-tools/bin/sqlcmd -S $MIRTH_SQL_SERVER_NAME -U sa -P $MIRTH_DATABASE_PASSWORD \
            -Q "CREATE DATABASE mirthdb;"
    fi
fi

if [[ $MIRTH_TRANSFORM_PROPS = true ]]
then
    java set_props $MIRTH_PROP_FILE
fi

java -jar mirth-server-launcher.jar &

echo waiting for mirth...
while ! nc -z localhost 8443
do
    sleep 1
done

if $isSqlServer ;
then
    echo initializing user
    /opt/mssql-tools/bin/sqlcmd -S $MIRTH_SQL_SERVER_NAME -U sa \
            -P $MIRTH_DATABASE_PASSWORD -i "/app/init.sql" \
            >> /dev/null
fi

mirth_script=/app/mirth.script

cat > $mirth_script

if [[ "$MIRTH_ADMIN_PASSWORD" != "" ]]
then
    echo user changepw admin $MIRTH_ADMIN_PASSWORD >> $mirth_script
fi

if  [[ "$MIRTH_CONFIG_FILE" != "" && -f $MIRTH_CONFIG_FILE ]]
then
    echo importcfg $MIRTH_CONFIG_FILE >> $mirth_script
else
    echo no configuration file could be located or none was \
        specified
fi

if [ -s $mirth_script ]
then
    java -jar mirth-cli-launcher.jar -a https://localhost:8443 \
        -u admin -p admin -v 0.0.0 -s /app/mirth.script
fi

wait