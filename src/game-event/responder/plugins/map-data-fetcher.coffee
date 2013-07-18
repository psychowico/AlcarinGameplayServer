'use strict'

db     = require '../../../tool/mongo'
log    = require '../../../logger'
time   = require('../../../tool/gametime')
Q      = require 'q'
Config = require('../../../config').game.character

map    = db.collection 'map'

fetchTerrain = (socket, character)->
    center = character.loc
    radius = Math.round character.viewRadius()
    conditions =
        'loc':
            '$geoWithin':
                # we calc territory in integers numbers
                '$center': [ [Math.round(center.x), Math.round(center.y)], radius ]
        # only fields with information about territory ("land")
        'land': {'$exists': 1}
    fields = ['land', 'loc']

    fetchingTime = time.GameTime()
    cursor = map.find conditions, fields
    fetching = Q.ninvoke cursor, 'toArray'
    result = Q.all([fetchingTime, fetching]).spread (gametime, fields)->
        info =
            radius        : character.viewRadius()
            lighting      : gametime.lighting().intensity
            charViewRadius: character.charViewRadius()
            talkRadius    : Config.talkRadius

        socket.emit 'terrain.swap', fields, info
    result.done()


module.exports =
    'swap.terrain': fetchTerrain