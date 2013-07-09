'use strict'

db  = require '../../../tool/mongo'
Q   = require 'q'

chars = db.collection('map.chars')

fetchCharacter = (socket, character, fetchId)->
    fetching = Q.ninvoke chars, 'findOne', {'_id': fetchId}
    fetching.done (character)->
        socket.emit 'char.fetch', character

module.exports =
    'fetch.char': fetchCharacter