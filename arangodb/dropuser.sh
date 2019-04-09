#!/bin/sh
# arangodb connection string shell variables default used if not set
# server-name     ar-server
# username        ARUSR default aruser
# user passwd     ARPWD postgres password if stop user password not in ~/.arpass file
# database name   ARDBN default testdb
# database passwd ARPASSWORD default 'pleasechangeme'

#ARUSR=raven

# get passwords and set default values for shell variables
. ./ar-env.sh

USR=${1:-${ARUSR}}

if [ "x"${USR} = "x"${ARUSR} ]; then
    echo "User is administrator ${ARUSR}"
    exit 1
fi

# Stop unless ~/.aqlpass file permissions are 0600
if [ "x"$(stat -c %a ${HOME}/.aqlpass) != "x600" ]
then
    echo "Set permission on ~/.aqlpass to 0600 or nosuch file"
    exit 1
fi

PWD=$(jq -r '.'${USR}' | select(. != null)' ${HOME}/.aqlpass)
if [ "x"${PWD} = "x" ]
then
    echo "No password set in the .aqlpass file for user ${USR}"
    exit 1
fi

# drop user
node <<@@EOF1
request = require('request');
function deleteuser() {
    request.delete('http://root:${ARPASSWORD}@${ARSVR}:8529/_api/user/${USR}')
}
deleteuser();
@@EOF1
