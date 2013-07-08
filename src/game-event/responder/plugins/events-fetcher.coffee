'use strict'

db  = require '../../../tool/mongo'
log = require '../../../logger'
Q   = require 'q'

resolveEvents = require('../../resolver').resolveAll

fetchEvents = (socket, character)->
    conditions =
        'char': character._id

    cursor = db.collection('map.chars.events').find conditions
    fetching = Q.ninvoke cursor, 'toArray'

    processAndSendEvents = (events)->
        processing = resolveEvents character, events
        processing.done (result)->
            socket.emit 'reset-events', result

    fetching.done processAndSendEvents, (err)-> log.error err


module.exports =
    'fetch-all-events': fetchEvents