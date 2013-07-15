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

    fetchingTime = time.timestamp()
    cursor = map.find conditions, fields
    fetching = Q.ninvoke cursor, 'toArray'
    result = Q.all([fetchingTime, fetching]).spread (timestamp, fields)->
        gametime = new time.GameTime(timestamp)
        localhour = gametime.localhour(center)

        lighting = 1 - (localhour / 48)
        if localhour > 48
            lighting = 1 - ( 2 - localhour / 48)
        socket.emit 'terrain.swap', fields,
            radius: character.viewRadius()
            charViewRadius: character.charViewRadius()
            lighting: lighting
    result.done()


module.exports =
    'swap.terrain': fetchTerrain