'use strict'

TimeOfDay = require '../../../game-object/descriptions/time-of-day'
GameTime  = require '../../../tool/gametime'

# fetching only characters positions and names
swapDescriptions = (socket, viewer)->
    TimeOfDay().done (description)->
        socket.emit 'descriptions.swap', description

module.exports =
    'swap.descriptions': swapDescriptions