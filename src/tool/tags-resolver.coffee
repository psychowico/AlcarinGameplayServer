'use strict'

###
resolve translation tag to his value (or translation tags group).
returns Q promises. always resolve promise - to empty string if data
can not be find in database
###

Q  = require 'q'
db = require './mongo'

# return promise of tag value (resolving to empty string if any problems)
exports.resolveTag = (tag)->
    deferred = Q.defer()

    fetching = Q.ninvoke db.collection('translations'), 'findOne', {_id: tag}
    fetching.done (result)-> deferred.resolve result?.val or ''
    fetching.fail -> deferred.resolve ''

    deferred.promise

# promise of object where keys are given tags and values are tag
# db values (empty if can not resolving)
exports.resolveTags = (tags)->
    deferred = Q.defer()

    response = {}
    response[tag] = '' for tag in tags

    query = db.collection('translations').find { _id: {$in: tags} }
    fetching = Q.ninvoke query, 'toArray'
    fetching.done (result)->
        result = result or []
        for obj in result
            response[obj._id] = obj.val
        deferred.resolve response
    fetching.fail -> deferred.resolve response

    deferred.promise