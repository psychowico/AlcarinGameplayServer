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
            @propertiesToSave = (key for key, prop of source)
            @[key] = prop for key, prop of source

    broadcast: (gameEvent)->
        # any time creating new broadcaster - because of
        # problems with gameEvent async setting. GC should
        # clean it.
        new Broadcaster @, gameEvent

    squeeze: ->
        type: 'char'
        id: @_id

    # max character view radius
    viewRadius: -> config.viewRadius

    # traveling current speed (if traveling) per hour
    speed: -> config.travelingSpeed

    # characters are fully visible only on short view radius
    charViewRadius: -> 1 * config.viewRadius / 3

    # name promise, watcher by viewer. not including distance
    resolveName: (viewer)-> NameResolver.resolveName @, viewer

    # name promise, watcher by viewer. not including distance
    # it need viewer only for language choose
    resolveNaturalName: (viewer)-> NameResolver.resolveNaturalName @, viewer

    distanceTo: (obj)->
        Math.sqrt Math.pow(obj.loc.x - @loc.x, 2) + Math.pow(obj.loc.y - @loc.y, 2)

    # save specific character struct fields
    save: (fields)=>
        fields = [fields] if fields and not Array.isArray fields
        data = {}
        for key in fields or @propertiesToSave
            val = @
            val = val[part] for part in key.split '.'
            data[key] = val
        query = {_id: @_id}
        data = {$set: data} if fields
        Q.ninvoke db.collection('map.chars'), 'update', query, data, {}

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

