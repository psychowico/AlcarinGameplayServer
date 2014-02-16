"use strict"

Q          = require 'q'
db         = require '../tool/mongo'
chars      = db.collection('map.chars')

class Place

    @places: {}

    constructor: (@_id)->

    charsCount: ->
        Q.ninvoke chars, 'count', {'loc.place': @_id}

    @fromId: (id)->
        if not @places[id]?
            @places[id] = new Place id
        return @places[id]


module.exports = Place
