'use strict'

###
Returning "Character" class. It has static factory methods that returning
Character object promise.
###

db           = require '../tool/mongo'
Q            = require 'q'
config       = require('../config').game.character

NameResolver = require('./char-resolver')

Broadcaster = require '../game-event/broadcaster'

class Character

    constructor: (source)->
        if source
            @[key] = prop for key, prop of source

    broadcast: (gameEvent)->
        # any time creating new broadcaster - because of
        # problems with gameEvent async setting. GC should
        # clean it.
        new Broadcaster @, gameEvent

    squeeze: ->
        type: 'char'
        id: @_id

    viewRadius: -> config.viewRadius

    # characters are fully visible only on short view radius
    charViewRadius: -> 1 * config.viewRadius / 3

    # name promise, watcher by viewer. not including distance
    resolveName: (viewer)-> NameResolver.resolveName @, viewer

    # name promise, watcher by viewer. not including distance
    # it need viewer only for language choose
    resolveNaturalName: (viewer)-> NameResolver.resolveNaturalName @, viewer

    distanceTo: (obj)->
        Math.sqrt Math.pow(obj.loc.x - @loc.x, 2) + Math.pow(obj.loc.y - @loc.y, 2)

    @fromId = (id)->
        return Q.reject 'Invalid charid.' if not db.ObjectId.isValid id
        deferred = Q.defer()

        resolveCharClass = (result)->
            _char = new Character result
            deferred.resolve _char

        # fetch character data and resolve character promise
        charpromise = Q.ninvoke db.collection('map.chars'), 'findOne', {'_id': db.ObjectId id}
        charpromise.done resolveCharClass, deferred.reject

        deferred.promise

module.exports = Character

