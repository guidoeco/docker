#!/bin/sh 
# arangodb connection string shell variables default used if not set
# server-name     ar-server
# username        ARUSR default aruser
# user passwd     ARPWD postgres password if stop user password not in ~/.arpass file
# database name   ARDBN default testdb
# database passwd ARPASSWORD default 'pleasechangeme'

#ARUSR=raven
#ARPASSWD=corvid

# get passwords and set default values for shell variables
. ./ar-env.sh

USR=${1:-${ARUSR}}

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

# create user and grant user permissions (default 'r') to database
PWR=${2:-'ro'}

node <<@@EOF1
const request = require('request');
function createuser() {
    return new Promise(function() {request.post('http://root:${ARPASSWORD}@${ARSVR}:8529/_api/user',
		             { json: { 'user': '${USR}', 'passwd': '${ARPWD}' }},
		             function (error, response, body) {
		                 if (!error && response.statusCode == 200) { console.log(body); }
                        if (error) { console.error(error); }
		             })});
};
function grantpermissions() {
    request.put('http://root:${ARPASSWORD}@${ARSVR}:8529/_api/user/${USR}/database/${ARDBN}',
		            { json: { 'grant': '${PWR}' }},
	              function (error, response, body) {
		                if (!error && response.statusCode == 200) {
			                     console.log(body)
		                   }
	              });
};

createuser().then(grantpermissions());
@@EOF1
