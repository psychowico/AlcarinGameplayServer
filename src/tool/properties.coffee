'use strict'

db = require './mongo'
Q  = require 'q'

exports.get = (key, defaultVal)->
    fullkey = "properties.#{key}"

    query =
        'loc.x': 0
        'loc.y': 0
    query[fullkey] = {'$exists': true}

    fetching = Q.ninvoke db.collection('map'), 'findOne', query, [fullkey]
    return fetching.then (result)->
        return defaultVal if not result?
        result.properties[key]

exports.set = (key, val)->
    fullkey = "properties.#{key}"
    query =
        'loc.x': 0
        'loc.y': 0
    data = {$set: {}}
    data.$set[fullkey] = val
    options = {upsert: true}

    Q.ninvoke db.collection('map'), 'update', query, data, options