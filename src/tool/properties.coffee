'use strict'

db = require './mongo'
Q  = require 'q'

exports.get = (key)->
    fullkey = "properties.#{key}"

    query =
        'loc.x': 0
        'loc.y': 0
    query[fullkey] = {'$exists': true}

    fetching = Q.ninvoke db.collection('map'), 'findOne', query, [fullkey]
    return fetching.then (result)->
        result.properties[key]
