'use strict'

properties = require './properties'

currTime = -> Math.round(new Date().getTime() / 1000)
defaultStruct = ->
    'last_game_timestamp': 0
    'last_real_timestamp': currTime()
    'freeze'             : false

exports.timestamp = ->
    properties.get('time').then (timeStruct)->
        timeStruct = timeStruct or defaultStruct()

        real = timeStruct.last_real_timestamp
        time = timeStruct.last_game_timestamp
        if not timeStruct.freeze then time += currTime() - real
        return time
