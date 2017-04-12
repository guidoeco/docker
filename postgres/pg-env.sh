#!/bin/sh
# postgres connection string shell variables default used if not set
# server-name     pg-server
# username        PGUSR default pguser
# user passwd     PGPWD postgres password stop if not in ~/.pgpass file
# database name   PGDBN default same as username
# database passwd PGPASSWORD default 'pleasechangeme'

# Permissions on the .pgpass file are 0600 or stop
if [ "x"$(stat -c %a ${HOME}/.pgpass) != "x600" ]
then
    echo "Set ~/.pgpass should be set 0600 or no nosuch file"
    exit 1
fi

PGSVR=pg-server
PGUSR=${PGUSR:-pguser}
PGDBN=${PGDBN:-${PGUSR}}

# Either the user passwd set for the PGUSR in the ~/.pgpass file or stop
PGPWD=${PGPWD:-$(sed -n 's/^'${PGSVR}':\(.*\):'${PGDBN}':'${PGUSR}':\(.*\)$/\2/p' ${HOME}/.pgpass)}
if [ "x"${PGPWD} = "x" ]
then
    echo "No password set in the .pgpass file for user ${PGUSR}"
    exit 1
fi

#The database password is either set in the shell variable PGDBPWD, set for the postgre user and database in the ~/.pgpass file, or 'pleasechangeme'
PGPASSWORD=${PGPASSWORD:-$(sed -n 's/^'${PGSVR}':\(.*\):postgres:postgres:\(.*\)$/\2/p' ${HOME}/.pgpass)}
PGPASSWORD=${PGPASSWORD:-pleasechangeme}
