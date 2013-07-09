'use strict'

###
Returning "Character" class. It has static factory methods that returning
Character object promise.
###

db = require '../tool/mongo'
Q  = require 'q'

Broadcaster = require '../game-event/broadcaster'

class Character

    broadcast: (gameEvent)->
        # any time creating new broadcaster - because of
        # problems with gameEvent async setting. GC should
        # clean it.
        new Broadcaster @, gameEvent

    squeeze: ->
        type: 'char'
        id: @_id

    @fromId = (id)->
        return Q.reject 'Invalid charid.' if not db.ObjectId.isValid id
        deferred = Q.defer()

        resolveCharClass = (result)->
            _char = new Character()
            _char[key] = prop for key, prop of result
            deferred.resolve _char

        # fetch character data and resolve character promise
        charpromise = Q.ninvoke db.collection('map.chars'), 'findOne', {'_id': db.ObjectId id}
        charpromise.done resolveCharClass, deferred.reject

        deferred.promise

module.exports = Character