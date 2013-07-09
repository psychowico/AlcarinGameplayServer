'use strict'

db  = require '../../../tool/mongo'
log = require '../../../logger'
Q   = require 'q'

game   = require('../../../config').game
map    = db.collection 'map'

fetchTerrain = (socket, character)->
    viewRadius = game.character['day-view-radius']
    center     = character.loc
    conditions =
        'loc':
            '$within':
                '$box': [
                    [center.x - viewRadius, center.y - viewRadius],
                    [center.x + viewRadius, center.y + viewRadius],
                ]
        # only fields with information about territory ("land")
        'land': {'$exists': 1}
    fields = ['land', 'loc']

    cursor = map.find conditions, fields
    fetching = Q.ninvoke cursor, 'toArray'
    fetching.done (fields)->
        socket.emit 'terrain.swap', viewRadius, fields


module.exports =
    'swap.terrain': fetchTerrain