'use strict'

TimeOfDay = require '../../../game-object/time-of-day'
GameTime  = require '../../../tool/gametime'

# fetching only characters positions and names
swapDescriptions = (socket, viewer)->
    GameTime.timestamp().done (gametime)->
        fetching = TimeOfDay.description gametime, viewer.loc
        fetching.done (description)->
            socket.emit 'descriptions.swap', description

module.exports =
    'swap.descriptions': swapDescriptions