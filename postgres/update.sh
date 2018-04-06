#!/bin/sh
# postgres connection string shell variables default used if not set
# server-name     pg-server
# username        PGUSR default pguser
# user passwd     PGPWD postgres password stop if not in ~/.pgpass file
# database name   PGDBN default same as username
# database passwd PGPASSWORD default 'pleasechangeme'

# customise by uncommenting variables below
# PGUSR=raven
# PGDBN=corvid

psql --version
if [ $? -ne 0 ]; then
    echo Error: install psql client
    exit 1
fi

echo $PGUSR $PGDBN
. ./pg-env.sh

sh ./stop.sh

docker rm postgres-instance
docker run --name postgres-instance --net dockernet --ip 172.18.1.6 --volumes-from postgres-persist -e POSTGRES_PASSWORD=${PGPASSWORD} -d postgres


export PGPASSWORD=${PGPASSWORD:-pleasechangeme}
while true;
do
    echo "waiting for database"
    (echo "\copyright" | psql -U postgres -h ${PGSVR}) 2> /dev/null && break
    sleep 1
done

psql -U postgres -h ${PGSVR} <<EOF
create user ${PGUSR};
create database ${PGDBN};
grant all privileges on database ${PGDBN} to ${PGUSR};
alter user ${PGUSR} with encrypted password '${PGPWD}';
EOF
