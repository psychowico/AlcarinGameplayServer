'use strict'

###
# Resolving events mean getting true text for gameevnt tagid and texts for
# gameevent arguments. for sample, specific character name in eyes of current
# character.
# Here I was learn to use Q 'promises' system.
###

Q           = require 'q'
resolveTags = require('../../tool/tags-resolver').resolveTags
db          = require '../../tool/mongo'
log         = require '../../logger'
_           = require 'underscore'

# let load all game events resolvers. event resolver should
# resolve event to text, or return false/nothing

loadGameEventResolvers = ->
    resolvers = []
    require('fs').readdirSync("#{__dirname}/event-resolvers").forEach (file)->
        resolvers.push require "./event-resolvers/#{file}"
    resolvers.sort (a,b)-> (a.priority or 0) - (b.priority or 0)
    return resolvers

resolvers = loadGameEventResolvers()

# return promise of copy of gameEvents array,
# with tagid's resolved to texts.
resolveTexts = (gameEvents, lang)->
    deferred = Q.defer()
    tags = []
    dict = {}
    _gameEvents = _.clone gameEvents
    for gameEvent in _gameEvents
        key = "events.#{gameEvent.tagid}.#{gameEvent.variety}.#{lang}"
        dict[key] = dict[key] or []
        dict[key].push gameEvent
        tags.push key

    resolving = resolveTags tags
    resolving.done (result)->
        for key, _events of dict
            text = result[key]
            if text and text.length > 0
                for gameEvent in _events
                    gameEvent.text = text
        deferred.resolve _gameEvents
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
            log.error 'Error while resolving GameEvent argument: #{err}'
            resolveStack()

    resolveStack().done (val)->
        if val == 'arg.resolved'
            deferred.reject()
        else
            deferred.resolve
                text  : val
                __base: gameEventArg

    deferred.promise

saveGameEvent = (char, gameEvent)->
    changes = {args: gameEvent.args}
    changes.text = gameEvent.text if gameEvent.text?
    db.collection('map.chars.events').update {_id: gameEvent._id},
        $set: changes

# return array of resolved gameEvents, for specific character.
resolveAll = (_char, gameEvents)=>
    deferred = Q.defer()
    lang = _char.lang or 'pl'
    tasks = []

    resolveTexts(gameEvents, lang).done (_gameEvents)=>
        for gameEvent in _gameEvents
            # we not processing "system" events, that won't displaying
            # for user on event list
            continue if gameEvent.system
            gameEventTasks = []
            # we clone it to not modyfi originl gameEvents array
            gameEvent.args = _.clone gameEvent.args

            for i in [0..gameEvent.args.length - 1]
                arg = gameEvent.args[i]
                neededArg = (gameEvent.text and gameEvent.text.indexOf("%#{i}") != -1)
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
                Q.allSettled(gameEventTasks).done (results)->
                    # if any of argument are resolved properly - it's mean
                    # we have some changes in GameEvent and need save it.
                    for result in results
                        if result.state is "fulfilled"
                            saveGameEvent _char, gameEvent
                            break

        resolveAllTasks = -> deferred.resolve _gameEvents
        Q.all(tasks).done resolveAllTasks, resolveAllTasks

    deferred.promise

exports.resolveAll = resolveAll