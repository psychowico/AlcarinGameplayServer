'use strict'

###
Starting GameClientServer and GameAppServer
###

log              = require './logger'
GameClientServer = require './server/browser'
GameAppServer    = require './server/app'
repl             = require './tool/repl-support'
gameloop         = require './gameloop'

GameClientServer.start()
    .then(GameAppServer.start)
    .then(gameloop.start)
    .done -> repl.setHook()