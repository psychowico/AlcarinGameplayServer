'use strict';
var mongo, mongoid, _mongo;

_mongo = require('mongodb');

mongo = _mongo.MongoClient;

mongoid = _mongo.ObjectID;

exports.init = function(config) {
  return function(sessionid, charid, callback, error_callbak) {
    return mongo.connect(config.mongo_connection_string, function(err, db) {
      return db.collection('app.sessions', function(err, collection) {
        return collection.findOne({
          _id: sessionid,
          name: 'alcarin'
        }, {
          lifetime: 1,
          modified: 1,
          player: 1
        }, function(err, doc) {
          var modified, now;

          if (doc != null) {
            modified = doc.modified.getTime() / 1000;
            now = new Date();
            if (modified + parseInt(doc.lifetime < (now.getTime() / 1000))) {
              return error_callback('session expired.');
            } else {
              return db.collection('users', function(err, collection) {
                return collection.count({
                  _id: doc.player,
                  chars: mongoid(charid)
                }, function(err, size) {
                  if (size === 0) {
                    error_callback('have not permission');
                  }
                  return callback();
                });
              });
            }
          } else {
            return error_callback('session not exists');
          }
        });
      });
    });
  };
};
