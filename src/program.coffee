'use strict'

config = require './config.coffee'

client_server = require('./browser-proxy.coffee').init config
client_server.connect()

app_server = require('./app-proxy.coffee').init config
app_server.connect()