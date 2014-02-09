'use strict'

db     = require '../../../tool/mongo'
log    = require '../../../logger'
time   = require('../../../tool/gametime')
Q      = require 'q'
_      = require 'underscore'
Config = require('../../../config').game.character

map   = db.collection 'map'
plots = db.collection 'map.places.zones.plots'

fetchTerrain = (socket, character)->
    center = character.loc
    radius = Math.round character.viewRadius()

    geoConditions =
        'loc':
            '$geoWithin':
                # we calc territory in integers numbers
                '$center': [ [Math.round(center.x), Math.round(center.y)], radius ]

    # only fields with information about territory ("land")
    mapConditions = _.extend {'land': {'$exists': 1}}, geoConditions

    fetchingTime = time.GameTime()

    mapCursor = map.find mapConditions, ['land', 'loc']
    fetchingMap = Q.ninvoke mapCursor, 'toArray'
    plotsCursor = plots.find geoConditions
    fetchingPlots = Q.ninvoke plotsCursor, 'toArray'

    fetchAll = Q.all([fetchingTime, fetchingMap, fetchingPlots])
    fetchAll.spread (gametime, fields, plots)->
        plots = _.groupBy(plots, 'place')
        info =
            radius        : character.viewRadius()
            lighting      : gametime.lighting().intensity
            charViewRadius: character.charViewRadius()
            talkRadius    : Config.talkRadius
        socket.emit 'terrain.swap', fields, plots, info

    fetchAll.done()


module.exports =
    'swap.terrain': fetchTerrain
