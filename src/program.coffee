'use strict'

exports.start = ->
    config    = require './config'
    EventsBus = require './EventsBus'

    client_server = require('./browser-proxy').init EventsBus, config
    client_server.connect()

    app_server = require('./app-proxy').init EventsBus, config
    app_server.connect()