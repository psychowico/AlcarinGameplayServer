config = require '../config'

db = require('mongoskin').db config.mongo_connection_string, {safe: false}
db.ObjectId = db.ObjectID.createFromHexString

module.exports = db