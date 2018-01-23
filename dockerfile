FROM postgres:latest

RUN apt-get update \ 
    && apt-get install -y --no-install-recommends barman gettext-base \ 
    && rm -rf /var/lib/apt/lists/*

ENV \
    DATA_DIR=/var/lib/barman \
    BACKUP_NAME=prod-core \
    BACKUP_DESCRIPTION="This is production backup" \
    IP_HOST=pg \
    DB_USERNAME=flazz \
    DB_NAME=postgres \
    DB_PORT=5432 \
    DB_PASS=qwer1234 \
    SLOT_NAME=barman 

COPY barman.conf /etc/barman.conf
COPY .pgpass.template /
COPY backup.conf.template /etc/barman.d/

VOLUME ${DATA_DIR} 

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail -f /dev/null"]
