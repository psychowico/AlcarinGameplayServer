'use strict'

###
Starting GameClientServer and GameAppServer
###

GameClientServer = require './server/browser'
GameAppServer    = require './server/app'

client_server = new GameClientServer()
client_server.start()

app_server = new GameAppServer()
app_server.start()