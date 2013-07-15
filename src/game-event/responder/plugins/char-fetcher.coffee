'use strict'

db  = require '../../../tool/mongo'
Q   = require 'q'

Character = require '../../../game-object/character'
chars = db.collection('map.chars')

# promise of character representation
# but this, who are only partialy visible
prepareMinimumCharsData = (charsObj, viewer)->
    promises = []
    for _char in charsObj
        resolving = _char.resolveNaturalName viewer
        do (_char)->
            promises.push resolving.then (naturalName)->
                Q.resolve
                    _id : _char._id
                    loc : _char.loc
                    name: naturalName

    Q.allSettled(promises).then (results)->
        return (result.value for result in results)

specifyCharVisibility = (viewer, char)->
    return 'full' if viewer._id.equals char._id
    distance = viewer.distanceTo char

    return 'full' if distance < viewer.charViewRadius()
    return 'partial' if distance < viewer.viewRadius()
    return 'reject'

fetchCharacter = (socket, viewer, fetchId)->
    return if not db.ObjectId.isValid fetchId
    id = db.ObjectId fetchId
    fetching = Q.ninvoke chars, 'findOne', {'_id': id}
    fetching.done (character)->
        switch specifyCharVisibility viewer, character
            when 'full'
                # fully visible character
                result = character
                result.mode = 'full'
                socket.emit 'char.fetch', result
            when 'partial'
                # we are to far and can not recognize this
                # character exacly.
                charObj = new Character character
                prepareMinimumCharsData([charObj], viewer).done (data)->
                    socket.emit 'char.fetch', data[0]

# starting current character travel
moveCharacter = (socket, viewer, target)->
    return if not target? or not target.x? or not target.y?

    viewer.move = viewer.move or {}
    viewer.move.target = target
    viewer.save 'move.target'

    socket.emit 'char.fetch', viewer

# fetching only characters positions and names
swapCharactersAround = (socket, viewer)->
    center     = viewer.loc
    conditions =
        'loc':
            '$geoWithin':
                '$center': [ [center.x, center.y], viewer.viewRadius() ]
    cursor = chars.find conditions
    fetching = Q.ninvoke cursor, 'toArray'
    fetching.done (chars)->
        result    = []
        minResult = []
        for _char in chars
            charObj = new Character _char
            visibility = specifyCharVisibility viewer, charObj
            switch visibility
                when 'full' then result.push _char
                when 'partial' then minResult.push charObj
        prepareMinimumCharsData(minResult, viewer).done (data)->
            socket.emit 'chars.swap', result.concat data

module.exports =
    'fetch.char': fetchCharacter
    'move.char' : moveCharacter
    'swap.chars': swapCharactersAround