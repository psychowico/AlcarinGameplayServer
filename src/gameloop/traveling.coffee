'use strict'

log        = require '../logger'
Q          = require 'q'
db         = require '../tool/mongo'

Character  = require '../game-object/character'
Vector     = require('sylvester').Vector
EventsBus  = require '../events-bus'
GameEvent  = require '../game-event'

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
    if dTime <= 0
        Q.resolve()
        return

    # speed per second
    speed     = dTime * character.speed() / SEC_IN_HOUR
    target    = character.move.target

    vloc    = Vector.create [character.loc.x, character.loc.y]
    vtarget = Vector.create [target.x, target.y]
    vdir    = vtarget.subtract(vloc).toUnitVector()

    vnewLoc  = vloc.add vdir.x(speed)

    # check that we are crossed target position
    vnewdir    = vtarget.subtract(vnewLoc).toUnitVector()
    if vnewdir.isAntiparallelTo vdir
        # we cross the target place, need stop character
        vnewLoc = vtarget
        character.loc =
            x: vnewLoc.e 1
            y: vnewLoc.e 2
        character.move.target = null
        character.move.last_update = null
        saving = character.save ['loc', 'move.last_update', 'move.target']
    else if needUpdate vloc, vnewLoc
        # let move chararacter a little.
        character.move.last_update = time
        character.loc =
            x: vnewLoc.e 1
            y: vnewLoc.e 2

        saving = character.save ['loc', 'move.last_update']
    if saving
        saving.done ->
            gameEvent = new GameEvent 'char.update', character._id, character.loc
            gameEvent.signAsTmp()
            character.broadcast(gameEvent).toWatchers()
        return saving

    Q.resolve()

update = (time)->
    deffered = Q.defer()

    cursor = chars.find {'move.target': {$ne: null}}
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