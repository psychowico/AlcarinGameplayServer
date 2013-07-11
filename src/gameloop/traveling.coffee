'use strict'

log        = require '../logger'
Q          = require 'q'
db         = require '../tool/mongo'

Character  = require '../game-object/character'
Vector     = require('sylvester').Vector
EventsBus  = require '../events-bus'

chars = db.collection('map.chars')

SEC_IN_HOUR = 60 * 60

needUpdate = (oldPosVector, newPosVector)->
    for ith in [1..2]
        return true if Math.round(oldPosVector.e ith) != Math.round(newPosVector.e ith)
    return false

updateCharacter = (character, time)->
    if not character.move.last_update?
        character.move.last_update = time
        return character.save 'move.last_update'

    last  = character.move.last_update
    dTime = time - last

    vloc = Vector.create [character.loc.x, character.loc.y]
    # speed per second
    speed     = dTime * character.speed() / SEC_IN_HOUR
    vspeed    = Vector.create [speed, 0]
    # directory in radians
    dir       = character.move.dir

    vchange = vspeed.rotate dir, Vector.Zero 2
    newLoc  = vloc.add vchange

    if needUpdate vloc, newLoc
        character.move.last_update = time
        character.loc =
            x: newLoc.e 1
            y: newLoc.e 2

        saving = character.save ['loc', 'move.last_update']
        saving.then -> EventsBus.emit 'char.moved', character
        return saving

    Q.resolve()

update = (time)->
    deffered = Q.defer()

    cursor = chars.find {move: {$exists: true}}
    Q.ninvoke(cursor, 'toArray').done (chars)->
        if chars?
            tasks = []
            for charData in chars
                character = new Character charData
                tasks.push updateCharacter character, time

            Q.all(tasks).done deffered.resolve, deffered.reject
        else
            deffered.resolve()

    deffered.promise


exports.update = update