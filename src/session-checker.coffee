'use strict'

_mongo = require('mongodb')
mongo  = _mongo.MongoClient
mongoid  = _mongo.ObjectID


# checking than specific character belong to specific active session id
exports.init = (config)->
    (sessionid, charid, callback, error_callbak)->
        mongo.connect config.mongo_connection_string, (err, db)->
            db.collection 'app.sessions', (err, collection)->
                collection.findOne
                    _id: sessionid
                    name: 'alcarin'
                ,
                    lifetime: 1
                    modified: 1
                    player  : 1
                , (err, doc)->
                    if doc?
                        modified = doc.modified.getTime() / 1000
                        now = new Date()
                        if modified + parseInt doc.lifetime < (now.getTime() / 1000)
                            error_callback 'session expired.'
                        else
                            #this is active session. we need be sure
                            #that requested character belong to session owner
                            db.collection 'users', (err, collection)->
                                collection.count
                                    _id: doc.player
                                    chars: mongoid charid
                                , (err, size)->
                                    error_callback 'have not permission' if size == 0
                                    # success!
                                    callback()
                    else
                        error_callback 'session not exists'
