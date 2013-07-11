'use strict'

log        = require '../logger'
Q          = require 'q'
GameTime   = require '../tool/gametime'

Traveling  = require './traveling'

stopServer = false

recurrence = (interval=1000)-> setTimeout main, interval if not stopServer

main = ->
    GameTime.timestamp().done (current)->
        if not current?
            log.warning 'Cannot state current time. Main game loop will not be processing.'

        if current?
            updateAll(current).done -> recurrence()
        else
            recurrence 60000

updateAll = (time)->
    tasksList = [
        Traveling.update
    ]
    tasks = []
    for task in tasksList
        tasks.push Q(time).then task
    Q.all tasks

exports.start = ->
    stopServer = false
    main()
exports.stop = ->
    stopServer = true