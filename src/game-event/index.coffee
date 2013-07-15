'use strict'

GameTime    = require '../tool/gametime'
Q           = require 'q'

class GameEvent

    constructor: (@id, @args...)->

    # resolving event to db writeable hashkey object.
    # it use "now" as time.
    resolve: ->
        resolvingTime = GameTime.timestamp()
        resolvingTime.then (timestamp)=>
            data =
                time   : timestamp
                args   : @args
            if @tmp
                data.system = true
                data.id     = @id
            else
                data.tagid = @id

            return data

    signAsTmp: -> @tmp = true



module.exports = GameEvent