#!/bin/bash

set -e

#start SQL Server, start the script to create the DB and import the data, start the app
(cd /usr/src/icmdb && ./setupdb.sh && ./restore-backup.sh & )

exec /opt/mssql/bin/sqlservr
