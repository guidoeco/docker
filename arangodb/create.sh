#!/bin/sh
# arangodb connection string shell variables default used if not set
# server-name     ar-server
# username        ARUSR default aruser
# user passwd     ARPWD postgres password if stop user password not in ~/.arpass file
# database name   ARDBN default testdb
# database passwd ARPASSWORD default 'pleasechangeme'

# get root passwords and set default values for shell variables
. ./ar-env.sh

# drop and create arangodb docker instance
sh ./stop.sh
#docker pull arangodb/arangodb
docker rm arangodb3-instance

#uncomment to create a database with the 'rocksdb' storage engine
#docker run -e ARANGO_ROOT_PASSWORD=${ARPASSWORD} -e ARANGO_STORAGE_ENGINE=rocksdb -d --name arangodb3-instance --net dockernet --ip 172.18.1.3 --volumes-from arangodb3-persist -p 9000:8529 arangodb/arangodb

docker run -e ARANGO_ROOT_PASSWORD=${ARPASSWORD} -d --name arangodb3-instance --net dockernet --ip 172.18.1.3 --volumes-from arangodb3-persist -p 9000:8529 arangodb
