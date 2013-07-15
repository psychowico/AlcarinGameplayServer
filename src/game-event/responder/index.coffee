'use strict'

###
It load all modules from "./plugins" directory. It should return objects -
where keys are event names (to respond) and values are methods that will
be called when event occurred. methods will got two arguments - source socket
and target charater object (who got event).
###

class GameEventsResponser
    supportedEvents: {}
    swapEvents: {}

    constructor: (@client)->
        @loadPlugins()

    # let load all responder plugins.
    loadPlugins: ->
        files = require('fs').readdirSync("#{__dirname}/plugins")
        for file in files
            plugin = require "./plugins/#{file}"
            for key, fun of plugin
                @supportedEvents[key] = fun
                @swapEvents[key] = fun if key.indexOf('swap.') == 0

    has: (eventId)->
        return true if eventId is 'swap.all'
        @supportedEvents[eventId]?

    respond: (eventId, args)->
        @client.resolvingCharacter().done (_char)=>
            _args = [@client.socket, _char].concat args
            if eventId == 'swap.all'
                for key, pluginFun of @swapEvents
                    pluginFun.apply @, _args
            else
                @supportedEvents[eventId]?.apply @, _args


module.exports = GameEventsResponser