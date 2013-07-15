'use strict'

db  = require '../../../tool/mongo'
log = require '../../../logger'
Q   = require 'q'

Config    = require('../../../config').game.character
GameEvent = require '../../'

talkToAll = (socket, character, content)->
    return if not content? or content.length == 0
    gameEvent = new GameEvent 'public-talk', content, character.squeeze()
    character.broadcast(gameEvent).inRadius Config.talkRadius

module.exports =
    'public-talk': talkToAll