'use strict'

db = require './mongo'

exports.resolveTag = (tag, done)->
    db.collection('translations').findOne {_id: tag}, (err, response)->
        done response.val

exports.resolveTags = (tags, done)->
    db.collection('translations').find({ _id: {$in: tags} }).toArray (err, result)->
        response = {}
        for obj in result
            response[obj._id] = obj.val
        done response