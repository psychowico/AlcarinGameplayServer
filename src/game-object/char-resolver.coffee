'use strict'

###
character can be named in 2 ways.
first, if character watch himself, he see his original, given by player, name.
if event viewing character remember this character it's name is resolved
to name stored in character memory.
in other case, we render static translated character name, related to his age.
###

db         = require '../tool/mongo'
Q          = require 'q'
resolveTag = require('../tool/tags-resolver').resolveTag

resolveName = (character, viewer)->
    return character.name if character._id.equals viewer._id
    deferred = Q.defer()
    fetchingName = fetchGivenName character, viewer._id
    fetchingName.done deferred.resolve, ->
        resolveNaturalName(character, viewer).done deferred.resolve, deferred.reject
    deferred.promise

# name given to target by current character
fetchGivenName = (_char, _targetid)->
    q = Q.defer()

    args =
        who   : _char._id
        type  : 'char'
        target: _targetid

    remembering = Q.ninvoke db.collection('map.chars.memory'), 'findOne', args, ['val']
    remembering = remembering.then (result)->
        if result? then Q.resolve result.val else Q.reject()
    remembering.done q.resolve, q.reject
    q.promise

# natural name, related with character age
varieties = ['very-young', 'young', 'adult-male', 'middle-aged', 'ederly', 'old']
MAX_AGE = 140
resolveNaturalName = (char, viewer)->
    _targetid = viewer._id
    q = Q.defer()
    lang = char.lang or 'pl'

    fetchingNaturalName = Q.ninvoke db.collection('map.chars'), 'findOne',
        {_id: _targetid}, ['born']
    fetchingNaturalName.done (result)->
        born = result.born or 0
        max = varieties.length - 1
        index = Math.min Math.round(max * born / MAX_AGE), max
        index = Math.max 0, index
        variety = varieties[index]
        tag = "static.man-age.#{variety}.#{lang}"
        resolveTag(tag).then q.resolve

    q.promise

exports.resolveName        = resolveName
exports.resolveNaturalName = resolveNaturalName