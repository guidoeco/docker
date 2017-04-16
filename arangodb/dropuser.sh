#!/bin/sh
# arangodb connection string shell variables default used if not set
# server-name     ar-server
# username        ARUSR default aruser
# user passwd     ARPWD postgres password if stop user password not in ~/.arpass file
# database name   ARDBN default testdb
# database passwd ARPASSWORD default 'pleasechangeme'

# get passwords and set default values for shell variables
. ./ar-env.sh

# drop user
node <<@@EOF1
sync = require('sync');
request = require('request');
function deleteuser(callback) {
    request.delete('http://root:${ARPASSWORD}@${ARSVR}:8529/_api/user/${ARUSR}')
}
sync(function(){
	    deleteuser.sync(null);
	});
@@EOF1
