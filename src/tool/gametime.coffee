'use strict'

properties = require './properties'
Vector     = require('sylvester').Vector

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

DAY_SEC = 60 * 60 * 24 * 4
class GameTime
    constructor: (@timestamp)->

    # return 'noticeable' hour of day - related with
    # specific location on the world (because on the diffrent)
    # world location we have another lighting in diffrent hours
    localhour: (location, truncated=false)->

        axis = Vector.create [1, 0]
        vpos = Vector.create [location.x, location.y]
        angle = vpos.angleFrom axis
        angle = 2 * Math.PI - angle if location.y < 0

        rel = angle / (2* Math.PI)
        result = rel * 96 + @hour(false)
        result = Math.floor result if truncated
        return result % 96


    hour: (truncated=true)->
        hours = (@timestamp % DAY_SEC) / (60 * 60)
        hours = Math.floor hours if truncated
        return hours

exports.GameTime = GameTime
