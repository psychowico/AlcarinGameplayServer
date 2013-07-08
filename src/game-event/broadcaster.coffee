'use strict'

units = require '../tool/unit-converter'
db    = require '../tool/mongo'
_     = require 'underscore'

Q         = require 'q'
EventsBus = require '../events-bus'

charEvents = db.collection 'map.chars.events'

class Broadcaster

    constructor: (@owner, @gameEvent)->
        throw Error 'Broadcaster owner need have "loc" property.' if not @owner.loc?
        throw Error 'Broadcaster owner need have "_id" property.' if not @owner._id?
        throw Error 'Broadcaster target can not be undefined.' if not gameEvent?

    # sending 'others' gameevent variety to specific ids
    toIds: (ids)=>
        return if not @gameEvent?

        @gameEvent.resolve().done (result)=>
            for id in ids
                copy = _.clone result
                copy.variety = if @owner._id.equals id then 'std' else 'others'
                copy.char = id
                do (copy)->
                    publishingEvent = Q.ninvoke charEvents, 'insert', copy
                    publishingEvent.done ->
                        EventsBus.emit 'game-event.published', copy

    inRadius: (radiusInMeters)->
        return if not @gameEvent?

        center = @owner.loc
        @gameEvent.resolve().done (result)=>
            radius = units.fromMeters radiusInMeters
            cursor = db.collection('map.chars').find
                'loc':
                    '$geoWithin':
                        '$center': [ [center.x, center.y], radius ]
            , ['_id']
            fetchingChars = Q.ninvoke cursor, 'toArray'
            fetchingChars.done (idsObjects)=>
                @toIds (obj._id for obj in idsObjects)


module.exports = Broadcaster