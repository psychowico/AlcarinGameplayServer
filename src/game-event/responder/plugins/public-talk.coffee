'use strict'

db  = require '../../../tool/mongo'
log = require '../../../logger'
Q   = require 'q'

GameEvent = require '../../'

resolveEvents = require('../../../game-client/game-events-resolver').resolveAll

talkToAll = (socket, character, content)->
    return if not content? or content.length == 0
    gameEvent = new GameEvent 'public-talk', content, character.squeeze()
    character.broadcast(gameEvent).inRadius 15

module.exports =
    'public-talk': talkToAll