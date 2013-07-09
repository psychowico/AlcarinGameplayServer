'use strict'

###
Initializing one mongodb connection that will be available everywhere in application.
###

config = require '../config'

db = require('mongoskin').db config.mongo_connection_string, {safe: false}
db.ObjectId = db.ObjectID.createFromHexString

validationReg = new RegExp '^[0-9a-fA-F]{24}$'
db.ObjectId.isValid = (id)-> validationReg.test id

module.exports = db