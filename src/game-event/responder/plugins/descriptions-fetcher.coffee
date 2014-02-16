'use strict'

TimeOfDay = require '../../../game-object/descriptions/time-of-day'
GameTime  = require '../../../tool/gametime'
Q         = require 'q'

# fetching only characters positions and names
swapDescriptions = (socket, viewer)->
    TimeOfDay(viewer).done (description)->
        socket.emit 'descriptions.swap', description

# place description is for now - place name (named by char) and
# others characters count description tag
placeDescription = (socket, viewer)->
    fetchingPlaceName = viewer.memory().place viewer.loc.place, false
    countingChars = viewer.place().charsCount()
    Q.all([fetchingPlaceName, countingChars]).spread (placeName, charsCount)->
        dVersion = if placeName == false then 'nonamed' else 'named'
        fetchingDescr = viewer.transl 'static', "place-description-name.#{dVersion}"

        # cauze viewer is too in this place.
        chCount = charsCount - 1
        cVersion = if chCount == 0 then 'empty' else if chCount == 1 then 'one' else 'more'
        fetchingCharsPart = viewer.transl 'static', "place-description-chars.#{cVersion}"

        Q.all([fetchingDescr, fetchingCharsPart]).spread (descr1, descr2)->
            result = [
                {text: descr1, args: [placeName]},
                {text: descr2, args: [chCount]}
            ]
            socket.emit 'description.place', result



module.exports =
    'swap.descriptions': swapDescriptions
    'place.description': placeDescription
