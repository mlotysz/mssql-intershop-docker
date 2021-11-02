#!/bin/bash

#wait for the SQL Server to come up
wait-for-port --host=localhost --timeout=300 1433
sleep 5s

if [[ $(fgrep -ix $RESTOREDB <<< "TRUE") ]]; then
    echo "Database will be restored from backup: ${BACKUP} - all data are dropped."
    /opt/mssql-tools/bin/sqlcmd \
        -S localhost \
        -U sa \
        -P $SA_PASSWORD \
        -d master \
        -i restore-backup.sql
fi
