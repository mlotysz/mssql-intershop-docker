# -*- mode: makefile; -*-
# Used Linux tools: docker and docker-compose

@default:
	just --choose

# create DB image
build:
	docker-compose build --progress plain

run-db-only:
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
restore:
	echo 'Will restore DB from backup/intershop.db.backup file...'
	RESTOREDB='true' docker-compose up

# full test cycle
test:
	just reset
	just build
	just restore

# check size of db in container
size-of-icmdb:
	docker exec -ti mssql-server bash -c 'ls -alh /var/opt/mssql/data/icmdb.mdf'

# copy DB files as is
backup-db-files:
	echo 'Assuming db container is running...'
	docker cp mssql-server:/var/opt/mssql/data/icmdb.mdf .
	docker cp mssql-server:/var/opt/mssql/data/icmdb_log.ldf .
	ls -alh icmdb.mdf
