'use strict'

###
# Resolving events mean getting true text for gameevnt tagid and texts for
# gameevent arguments. for sample, specific character name in eyes of current
# character.
# Here I was learn to use Q 'promises' system.
###

Q           = require 'q'
resolveTags = require('../tool/tags-resolver').resolveTags
db          = require '../tool/mongo'

# let load all game events resolvers. event resolver should
# resolve event to text, or return false/nothing

loadGameEventResolvers = ->
    resolvers = []
    require('fs').readdirSync("#{__dirname}/event-resolvers").forEach (file)->
        resolvers.push require "./event-resolvers/#{file}"
    resolvers.sort (a,b)-> (a.priority or 0) - (b.priority or 0)
    return resolvers

resolvers = loadGameEventResolvers()

resolveTexts = (events, lang)->
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

resolveGameEventArg = (char, gameEvent, gameEventArg)->

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

saveGameEvent = (char, gameEvent)->
    eventId = db.ObjectId gameEvent._id.$id
    changes = {args: gameEvent.args}
    changes.text = gameEvent.text if gameEvent.text?
    db.collection('map.chars.events').update {_id: eventId},
        $set: changes

resolveAll = (_char, events)=>
    deferred = Q.defer()
    lang = _char.lang or 'pl'
    tasks = []
    texts = resolveTexts events, lang

    texts.then =>
        for gameEvent in events
            gameEventTasks = []
            for i in [0..gameEvent.args.length - 1]
                arg = gameEvent.args[i]
                neededArg = gameEvent.text.indexOf("%#{i}") != -1
                isArgObject = (typeof arg) is 'object'
                if not neededArg
                    gameEvent.args[i] = null
                continue if not isArgObject or not neededArg
                do (gameEvent, i, arg, gameEventTasks)->
                    resolvingArgument = resolveGameEventArg _char, gameEvent, arg
                    resolvingArgument.then (val)->
                        need_be_saved = true
                        gameEvent.args[i] = val
                    gameEventTasks.push resolvingArgument
                    tasks.push resolvingArgument
            do (gameEvent, gameEventTasks)->
                Q.allSettled(gameEventTasks).then (results)->
                    # if any of argument are resolved properly - it's mean
                    # we have some changes in GameEvent and need save it.
                    for result in results
                        if result.state is "fulfilled"
                            saveGameEvent _char, gameEvent
                            break

        Q.all(tasks).fin -> deferred.resolve events

    deferred.promise

exports.resolveAll = resolveAll