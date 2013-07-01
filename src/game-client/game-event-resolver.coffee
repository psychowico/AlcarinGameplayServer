'use strict'

###
# Resolving events mean getting true text for gameevnt tagid and texts for
# gameevent arguments. for sample, specific character name in eyes of current
# character.
# Here I was learn to use 'promises' system.
###

Q = require 'q'
resolveTags  = require('../tool/tags-resolver').resolveTags

# let load all game events resolvers. event resolver should
# resolve event to text, or return false/nothing
resolvers = []
require('fs').readdirSync("#{__dirname}/event-resolvers").forEach (file)->
    resolvers.push require "./event-resolvers/#{file}"
resolvers.sort (a,b)-> (b.priority or 0) - (a.priority or 0)

resolve_arg  = (char, arg, resolver, done)->
    return [char, arg, done] if done?
    deferred = Q.defer()
    resolver char, arg, (result)->
        if result?
            deferred.resolve [char, arg, result]
        else
            deferred.resolve [char, arg]
    deferred.promise

resolve_text = (events, lang)->
    def = Q.defer()
    tags = []
    dict = {}
    for ev in events
        key = "events.#{ev.tagid}.#{ev.variety}.#{lang}"
        dict[key] = [] if not dict[key]?
        dict[key].push ev
        tags.push key

    resolveTags tags, (result)->
        for key, _events of dict
            text = result[key] or ''
            for ev in _events
                ev.text = text
        def.resolve()
    def.promise

calc_args = (text)->
    index = 0
    index++ until text.indexOf "%#{index}" is -1
    return index + 1

module.exports = (char, events, done_callback)->
    _args = []
    lang = char.lang or 'pl'

    tasks = []
    texts = resolve_text events, lang

    task = (_resolver)->
        (char, arg, done) -> resolve_arg char, arg, _resolver, done

    texts.then =>
        for ev in events
            need_arg_count = calc_args ev.text
            index = 0
            for arg, ind in ev.args when typeof arg is 'object'
                promise = Q [char, arg]
                for resolver, key in resolvers
                    promise = promise.spread task resolver

                tasks.push do (ev, promise, ind)->
                    return promise.spread (char, arg, result)->
                        if result is true or not result?
                            ev.args[ind] = arg
                        else
                            ev.args[ind] =
                                text  : result
                                __base: arg
                        return [char, arg]
                index++
                break if index >= need_arg_count
        Q.all(tasks).then ->
            done_callback events