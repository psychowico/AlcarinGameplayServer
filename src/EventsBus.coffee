'use strict'

class EventsBus
    listeners = {}

    on: (name, meth)->
        listeners[name] = [] if not listeners[name]?
        listeners[name].push meth

    emit: (name, args...)->
        if listeners[name]?
            _meth.apply global, args for _meth in listeners[name]

module.exports = new EventsBus()