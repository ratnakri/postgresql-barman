#!/bin/bash

set -e


#this command will substitutes the values of environment variables 
cat /etc/barman.d/backup.conf.template | envsubst > /etc/barman.d/backup.conf
cat /.pgpass.template | envsubst > /var/lib/barman/.pgpass

# change the ownership to barman
# all barman command must run using user barman
# pgpass is stored in this directory 
chown -Rf barman.barman /var/lib/barman
chmod -R 0600 /var/lib/barman/.pgpass

# run pg_isready to check connection to database
# 0 = database accepting connection
# 1 = database rejecting connections
# 2 = database is down / no response
pg_isready \
	-h ${IP_HOST} \
	-U ${DB_USERNAME} \
	-p ${DB_PORT} \
	-d ${DB_NAME}

if ! [ $? == 0 ]; then
 	echo "Aborting all process"
	exit 1
fi

#checking availibility of replication slots
RESULT=`gosu barman psql \
	-h ${IP_HOST} \
        -U ${DB_USERNAME} \
        -p ${DB_PORT} \
        -d ${DB_NAME} \
	-c "select slot_name from pg_replication_slots where slot_name = '${SLOT_NAME}';"`

if [ "${RESULT}" == "${SLOT_name}" ]; then
	echo "${SLOT_NAME} is used by another process"
	exit 1
else
	gosu barman barman cron
	gosu barman barman receive-wal --create-slot ${BACKUP_NAME}
	gosu barman barman switch-xlog --force --archive ${BACKUP_NAME}
fi

#checking WAL archive status
WAL_ARCHIVE=`gosu barman barman check ${BACKUP_NAME} | grep "WAL archive"`

# if WALs are received, running initial backup
if [[ "${WAL_ARCHIVE}" == *"OK"* ]]; then
	gosu barman barman backup ${BACKUP_NAME}
	echo "Backup has setup successfully"
if

sleep 1234

exec "$@"
