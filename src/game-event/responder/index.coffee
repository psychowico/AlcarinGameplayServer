'use strict'

###
It load all modules from "./plugins" directory. It should return objects -
where keys are event names (to respond) and values are methods that will
be called when event occurred. methods will got two arguments - source socket
and target charater object (who got event).
###

class GameEventsResponser
    supportedEvents: {}

    constructor: (@client)->
        @loadPlugins()

    # let load all responder plugins.
    loadPlugins: ->
        files = require('fs').readdirSync("#{__dirname}/plugins")
        for file in files
            plugin = require "./plugins/#{file}"
            @supportedEvents[key] = fun for key, fun of plugin

    has: (eventId)->
        @supportedEvents[eventId]?

    respond: (eventId, args)->
        @client.character.done (_char)=>
            _args = [@client.socket, _char].concat args
            @supportedEvents[eventId].apply @, _args

module.exports = GameEventsResponser