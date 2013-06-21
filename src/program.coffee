'use strict'

config    = require './config.coffee'
EventsBus = require './EventsBus.coffee'

client_server = require('./browser-proxy.coffee').init EventsBus, config
client_server.connect()

app_server = require('./app-proxy.coffee').init EventsBus, config
app_server.connect()