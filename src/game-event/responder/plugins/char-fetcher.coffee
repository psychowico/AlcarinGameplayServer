'use strict'

db  = require '../../../tool/mongo'
Q   = require 'q'

chars = db.collection('map.chars')

fetchCharacter = (socket, character, fetchId)->
    return if not db.ObjectId.isValid fetchId
    id = db.ObjectId fetchId
    fetching = Q.ninvoke chars, 'findOne', {'_id': id}
    fetching.done (character)->
        socket.emit 'char.fetch', character

module.exports =
    'fetch.char': fetchCharacter