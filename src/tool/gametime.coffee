'use strict'

properties = require './properties'
Vector     = require('sylvester').Vector

currTime = -> Math.round(new Date().getTime() / 1000)
defaultStruct = ->
    'last_game_timestamp': 0
    'last_real_timestamp': currTime()
    'freeze'             : false

timestamp = ->
    properties.get('time').then (timeStruct)->
        timeStruct = timeStruct or defaultStruct()

        real = timeStruct.last_real_timestamp
        time = timeStruct.last_game_timestamp
        if not timeStruct.freeze then time += currTime() - real
        return time

DAY_SEC = 60 * 60 * 24 * 4
class GameTime
    constructor: (@timestamp)->

    hour: (truncated=true)->
        hours = (@timestamp % DAY_SEC) / (60 * 60)
        hours = Math.floor hours if truncated
        return hours

    # light intensity, from 0-1
    lighting: ->
        hour = @hour false
        switch
            when hour > 92 or hour <= 4
                _intensity = ((hour + 4) % 96) / 8
                _timeofday = 'morning'
            when hour > 4 and hour <= 44
                _intensity = 1
                _timeofday = 'day'
            when hour > 44 or hour <= 52
                _intensity = 1 - (hour % 44) / 8
                _timeofday = 'evening'
            when hour > 52 or hour <= 92
                _intensity = 0
                _timeofday = 'night'
            else throw Error "Can not choose lighting system. Wrong hour: #{hour}"
        return {
            intensity: _intensity
            timeofday: _timeofday
        }

exports.GameTime  = -> timestamp().then (time)-> new GameTime time
exports.timestamp = timestamp