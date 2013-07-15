'use strict'

units = require '../tool/unit-converter'
db    = require '../tool/mongo'
_     = require 'underscore'

Character = require '../game-object/character'
Q         = require 'q'
EventsBus = require '../events-bus'
Config    = require('../config').game.character

ClientsContainer = null
currentClients = ->
    ClientsContainer = require('../server/browser') if not ClientsContainer
    ClientsContainer.clients

charEvents = db.collection 'map.chars.events'

class Broadcaster

    constructor: (@owner, @gameEvent)->
        throw Error 'Broadcaster owner need have "loc" property.' if not @owner.loc?
        throw Error 'Broadcaster owner need have "_id" property.' if not @owner._id?
        throw Error 'Broadcaster target can not be undefined.' if not gameEvent?

    # sending 'others' gameevent variety to specific ids
    toChars: (chars)=>
        return if not @gameEvent?

        tmp = @gameEvent.tmp
        @gameEvent.resolve().done (result)=>
            for ch in chars
                id        = ch._id
                copy      = _.clone result
                copy.char = id
                if tmp
                    EventsBus.emit 'game-event.published', copy
                else
                    copy.variety  = if @owner._id.equals id then 'std' else 'others'
                    copy.response = true if @owner._id.equals id
                    do (copy)->
                        publishingEvent = Q.ninvoke charEvents, 'insert', copy
                        publishingEvent.done ->
                            EventsBus.emit 'game-event.published', copy

    # returning promise of array of Character objects
    # if this event is temporary - it will looking in logged
    # clients only. if not - it use database
    _charsInRadius: (radius)->
        deffered = Q.defer()
        owner  = @owner
        center = @owner.loc
        @gameEvent.resolve().done (result)=>
            if @gameEvent.tmp
                # we search only for characters that are connected now and are in specific distance
                promises = (client.resolvingCharacter() for id, client of currentClients())
                formatChars = (charsResult)->
                    chars = (obj.value for obj in charsResult when obj.state is 'fulfilled')
                    chars = (ch for ch in chars when ch.distanceTo(owner) <= radius)
                    deffered.resolve chars
                return Q.allSettled(promises).then formatChars, deffered.reject

            else
                # we search in database for all chars in this area
                cursor = db.collection('map.chars').find
                    'loc':
                        '$geoWithin':
                            '$center': [ [center.x, center.y], radius ]
                , ['_id']
                fetching = Q.ninvoke(cursor, 'toArray')
                fetching.fail deffered.reject
                fetching.then (data)->
                    deffered.resolve [] if not data?
                    deffered.resolve (new Character(charStruct) for charStruct in data)

        deffered.promise

    inRadius: (radius)=>
        return if not @gameEvent?

        fetchingChars = @_charsInRadius radius
        fetchingChars.done @toChars

    # gameevent will be sent only to characters who can see this character
    toWatchers: =>
        # we need broadcast event much long that character
        # view radius - because others chars can see more
        # that current.
        @_charsInRadius(Config.maxViewRadius).done (chars)=>
            # now we need check all characters that they can see target
            chars = (ch for ch in chars when ch.inViewRadius(@owner))
            @toChars chars

module.exports = Broadcaster