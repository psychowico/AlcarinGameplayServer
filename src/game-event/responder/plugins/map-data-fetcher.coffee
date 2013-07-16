'use strict'

db  = require '../../../tool/mongo'
log = require '../../../logger'
time = require('../../../tool/gametime')
Q        = require 'q'

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

    fetchingTime = time.GameTime()
    cursor = map.find conditions, fields
    fetching = Q.ninvoke cursor, 'toArray'
    result = Q.all([fetchingTime, fetching]).spread (gametime, fields)->
        socket.emit 'terrain.swap', fields,
            radius: character.viewRadius()
            charViewRadius: character.charViewRadius()
            lighting: gametime.lighting().intensity
    result.done()


module.exports =
    'swap.terrain': fetchTerrain