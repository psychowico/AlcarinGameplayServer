'use strict'

db  = require '../../../tool/mongo'
log = require '../../../logger'
Q   = require 'q'

map    = db.collection 'map'

fetchTerrain = (socket, character)->
    center     = character.loc
    conditions =
        'loc':
            '$geoWithin':
                '$center': [ [center.x, center.y], character.viewRadius() ]
        # only fields with information about territory ("land")
        'land': {'$exists': 1}
    fields = ['land', 'loc']

    cursor = map.find conditions, fields
    fetching = Q.ninvoke cursor, 'toArray'
    fetching.done (fields)->
        socket.emit 'terrain.swap', fields,
            radius: character.viewRadius()
            charViewRadius: character.charViewRadius()


module.exports =
    'swap.terrain': fetchTerrain