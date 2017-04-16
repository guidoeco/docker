#!/bin/sh 
# arangodb connection string shell variables default used if not set
# server-name     ar-server
# username        ARUSR default aruser
# user passwd     ARPWD postgres password if stop user password not in ~/.arpass file
# database name   ARDBN default testdb
# database passwd ARPASSWORD default 'pleasechangeme'

# get passwords and set default values for shell variables
. ./ar-env.sh

# create database, user and grant user read-write permissions to database 
node <<@@EOF2
sync = require('sync');
request = require('request');
function createdb(callback) {
    Database = require('arangojs').Database;
    db = new Database({url: 'http://root:${ARPASSWORD}@ar-server:8529', databaseName: '_system' });
    db.listDatabases()
    .then(names => { console.log('names: ', names);
    db.createDatabase('${ARDBN}')
    .then(info => { console.log('drop: ', info);
		    db.listDatabases()
    .then(names => { console.log('names: ', names)},
          err => { console.error('names error: ', err)})}),
    err => { console.error('error drop: ', err)}});
}
function createuser(callback) {
    request.post('http://root:${ARPASSWORD}@${ARSVR}:8529/_api/user',
		 { json: { 'user': '${ARUSR}', 'passwd': '${ARPWD}' }},
		 function (error, response, body) {
		     if (!error && response.statusCode == 200) {
			    console.log(body)
			}
		 });
};
function grantpermissions(callback) {
    request.put('http://root:${ARPASSWORD}@${ARSVR}:8529/_api/user/${ARUSR}/database/${ARDBN}',
		{ json: { 'grant': 'rw' }},
	     function (error, response, body) {
		 if (!error && response.statusCode == 200) {
			console.log(body)
		    }
	     });
};
sync(function(){
	    createdb.sync(null);
	});
sync(function(){
	    createuser.sync(null);
	});
sync(function(){
	    grantpermissions.sync(null);
	});
@@EOF2

