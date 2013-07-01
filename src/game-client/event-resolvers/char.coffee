'use strict'

db = require '../../tool/mongo'
Q  = require 'q'
resolveTag = require('../../tool/tags-resolver').resolveTag

# character can be named in 2 ways.
# first, if character watch himself, he see his original, given by player, name.
# if event viewing character remember this character it's name is resolved
# to name stored in character memory.
# in other case, we render static translated character name, related to his age.
module.exports = (char, arg, callback)->
    result = undefined
    if arg.type is 'char'
        if char.id is arg.id
            callback char.name
        else
            fetchGivenName(char, arg.id).then (val)->
                if val
                    callback val
                else
                    fetchNaturalName(char, arg.id).then (val)->
                        callback val
    else
        callback result

# name given to target by current character
fetchGivenName = (_char, _targetid)->
    q = Q.defer()
    db.collection('map.chars.memory').findOne
        who   : db.ObjectId _char.id
        type  : 'char'
        target: db.ObjectId _targetid
    , ['val'], (err, result)->
        if result? then q.resolve result.val else q.resolve ''
    q.promise

# natural name, related with character age
varieties = ['very-young', 'young', 'adult-male', 'middle-aged', 'ederly', 'old']
MAX_AGE = 140
fetchNaturalName = (char, _targetid)->
    q = Q.defer()
    lang = char.lang or 'pl'
    db.collection('map.chars').findOne {_id: db.ObjectId _targetid}, ['born'], (err, result)->
        born = result.born or 0
        max = varieties.length - 1
        index = Math.min Math.round(max * born / MAX_AGE), max
        variety = varieties[index]
        tag = "static.man-age.#{variety}.#{lang}"
        resolveTag tag, q.resolve

    q.promise