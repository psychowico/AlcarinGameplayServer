"use strict"

db         = require '../tool/mongo'
Q          = require 'q'
# memory     = db.collection('map.chars.memory')

class Place

    @places: {}

    constructor: ->

    @fromId: (id)->
        if not @places[id]?
            @places[id] = new Place
        return @places[id]


module.exports = Place
