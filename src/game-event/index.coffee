'use strict'

Broadcaster = require './broadcaster'
GameTime    = require '../tool/gametime'
Q           = require 'q'

class GameEvent

    constructor: (@id, @args...)->

    # resolving event to db writeable hashkey object.
    # it use "now" as time.
    resolve: ->
        resolvingParams = Q.all [GameTime.timestamp()]
        resolvingParams.spread (timestamp)=>
            time   : timestamp
            tagid  : @id
            args   : @args


module.exports = GameEvent