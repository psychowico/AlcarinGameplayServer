'use strict'

###
# Resolving events mean getting true text for gameevnt tagid and texts for
# gameevent arguments. for sample, specific character name in eyes of current
# character.
# Here I was learn to use Q 'promises' system.
###

Q           = require 'q'
resolveTags = require('../tool/tags-resolver').resolveTags

# let load all game events resolvers. event resolver should
# resolve event to text, or return false/nothing

loadGameEventResolvers = ->
    resolvers = []
    require('fs').readdirSync("#{__dirname}/event-resolvers").forEach (file)->
        resolvers.push require "./event-resolvers/#{file}"
    resolvers.sort (a,b)-> (a.priority or 0) - (b.priority or 0)
    return resolvers

resolvers = loadGameEventResolvers()

class GameEventsResolver

    @resolveTexts = (events, lang)->
        deferred = Q.defer()
        tags = []
        dict = {}
        for ev in events
            key = "events.#{ev.tagid}.#{ev.variety}.#{lang}"
            dict[key] = [] if not dict[key]?
            dict[key].push ev
            tags.push key

        resolving = resolveTags(tags)
        resolving.then (result)->
            for key, _events of dict
                text = result[key]
                for ev in _events
                    ev.text = text
            deferred.resolve()
        deferred.promise

    @resolveGameEventArg = (char, gameEvent, gameEventArg)->

        deferred = Q.defer()
        _resolvers = resolvers[..]

        resolveStack = (val)->
            isResolved = (val is 'arg.resolved') or _resolvers.length == 0
            return Q.resolve val if isResolved

            resolver  = _resolvers.pop()
            resolving = Q resolver char, gameEventArg

            resolving.then resolveStack, (err)->
                console.error 'Error while resolving GameEvent argument: #{err}'
                resolveStack()

        resolveStack().then (val)->
            if val == 'arg.resolved'
                deferred.reject()
            else
                deferred.resolve
                    text  : val
                    __base: gameEventArg

        deferred.promise

    @resolveAll = (_char, events)=>
        deferred = Q.defer()
        lang = _char.lang or 'pl'
        tasks = []
        texts = @resolveTexts events, lang

        texts.then =>
            for gameEvent in events
                for i in [0..gameEvent.args.length - 1]
                    arg = gameEvent.args[i]
                    neededArg = (typeof arg) is 'object' and gameEvent.text.indexOf("%#{i}") != -1
                    continue if not neededArg
                    do (gameEvent, i, arg)=>
                        resolvingArgument = @resolveGameEventArg _char, gameEvent, arg
                        resolvingArgument.then (val) -> gameEvent.args[i] = val
                        tasks.push resolvingArgument

            Q.all(tasks).fin -> deferred.resolve events

        deferred.promise

module.exports = GameEventsResolver