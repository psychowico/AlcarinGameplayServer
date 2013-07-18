'use strict'

log        = require '../logger'
Q          = require 'q'
db         = require '../tool/mongo'

Character  = require '../game-object/character'
Vector     = require('sylvester').Vector
EventsBus  = require '../events-bus'
GameEvent  = require '../game-event'
Units      = require '../tool/unit-converter'

chars = db.collection('map.chars')

SEC_IN_HOUR               = 60 * 60
MINIMUM_TRAVEL_DISTANCE   = Units.fromMeters 5
DISTANCE_TO_FOLLOW_TARGET = Units.fromMeters 15

needUpdate = (oldPosVector, newPosVector)->
    for ith in [1..2]
        return true if Math.abs(oldPosVector.e(ith) - newPosVector.e(ith)) >= MINIMUM_TRAVEL_DISTANCE
    return false

findTravelTarget = (character, target)->
    return switch target.type
        when 'char'
            # somebody try follow specific character.
            return Character.fromId(target.id).then (targetChar)->
                if character.inViewRadius(targetChar)
                    if character.distanceTo(targetChar) <= DISTANCE_TO_FOLLOW_TARGET
                        return Q.reject()
                    # we stop five meters before target
                    cloc = character.loc
                    tloc = targetChar.loc
                    vloc    = Vector.create [cloc.x, cloc.y]
                    vtarget = Vector.create [tloc.x, tloc.y]
                    vdir    = vtarget.subtract(vloc).toUnitVector().x(DISTANCE_TO_FOLLOW_TARGET)
                    target  = {x: tloc.x - vdir.e(1), y: tloc.y - vdir.e(2)}
                    return Q.resolve target
                else
                    character.move.target = null
                    character.move.last_update = null
                    character.save ['move.last_update', 'move.target']
                    return Q.reject()
        else return Q.reject()

updateCharacter = (character, time)->
    if not character.move.last_update?
        character.move.last_update = time
        return character.save 'move.last_update'

    last  = character.move.last_update
    dTime = time - last
    if dTime <= 0 then return Q.resolve()

    # speed per second
    speed   = dTime * character.speed() / SEC_IN_HOUR
    target  = character.move.target
    movable = false
    if target.type?
        # let check what is real target
        movable = true
        target = findTravelTarget character, target
    else
        target = Q.resolve target
    travel = (target)->
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
            if not movable
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
                gameEvent = new GameEvent 'char.update-location', {_id: character._id, loc: character.loc}
                gameEvent.signAsTmp()
                character.broadcast(gameEvent).toWatchers()
            return saving

        return Q.resolve()
    return target.then travel, (err)->
        log.error err if err

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