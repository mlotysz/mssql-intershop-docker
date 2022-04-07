# -*- mode: makefile; -*-

# Used Linux tools: bash, docker, docker-compose,  sqlcmd, xz, tar, pv

set dotenv-load := false

@default:
	just --choose

# create DB image
build:
	docker-compose build --progress plain

_run-db-only:
	docker-compose up

# run DB, SOLR and Mailhog
run:
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose-solr.yaml \
		-f docker-compose-mail.yaml \
		up --remove-orphans

# cleanup dangling containers and remove volumes (all)
reset:
	docker container prune
	docker-compose down -v

# start DB only and restore from backup
_restore:
	echo 'Will restore DB from backup/intershop.db.backup file...'
	RESTOREDB='true' docker-compose up

# full test cycle
test:
	just reset
	just build
	just _restore

# check size of db in container - local hacking purposes
_size-of-icmdb:
	docker exec -ti mssql-server bash -c 'ls -alh /var/opt/mssql/data/icmdb*'

# copy DB files as is - local hacking purposes
_backup-db-files:
	echo 'Assuming db container is running...' \
	&& docker cp mssql-server:/var/opt/mssql/data/icmdb.mdf . \
	&& docker cp mssql-server:/var/opt/mssql/data/icmdb_log.ldf . \
	ls -alh icmdb.mdf

# make DB backup archive
backup:
	# TODO switch to docker instead?
	sqlcmd -S localhost \
			-d icmdb \
			-U intershop \
			-P intershop \
			-Q "BACKUP DATABASE icmdb TO DISK = '/var/opt/mssql/data/intershop.db.backup' WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup of ICMDB';" \
	&& docker cp mssql-server:/var/opt/mssql/data/intershop.db.backup intershop.db.backup \
	&& source='intershop.db.backup' \
	&& source_size=$(du -sk "${source}" | cut -f1) \
	&& tar -cf - "${source}" \
			| pv -p -s "${source_size}k" -t \
			| xz --threads=0 -c - \
			> intershop.db.backup.txz - \
	&& rm intershop.db.backup \
	&& docker exec mssql-server rm /var/opt/mssql/data/intershop.db.backup
