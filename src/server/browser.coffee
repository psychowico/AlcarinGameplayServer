'use strict'

###
This server listening for webbrowser connection. For any connection it
generate GameClient object. It used socket.io for communication.
###

wildcard   = require 'socket.io-wildcard'
io         = wildcard require 'socket.io'
config     = require '../config'
EventsBus  = require '../events-bus'
GameClient = require '../game-client'
Q          = require 'q'
log        = require '../logger'


class BrowserProxy
    clients         : {}
    ungroupedClients: []

    start: ->
        deferred = Q.defer()

        @server = server = io.listen config.client_port, ->
            deferred.resolve server
            log.info "-- WebClient server ready, listening on #{config.client_port}"
        server.set 'log level', config.log_level
        server.sockets.on 'connection', @onClientConnected

        EventsBus.on 'web-client.disconnected', @onClientDisconnected
        EventsBus.on 'web-client.authorized', @onClientAuthorized
        EventsBus.on 'game-event.published', @publishEvent

        deferred.promise

    onClientConnected: (socket)=>
        @ungroupedClients.push new GameClient @, socket

    onClientAuthorized: (client)=>
        index = @ungroupedClients.indexOf client
        @ungroupedClients.splice index, 1
        @clients[client.charid] = client

    onClientDisconnected: (client)=>
        id = client.charid
        if id?
            delete @clients[client.charid]
        else
            index = @ungroupedClients.indexOf client
            @ungroupedClients.splice index, 1

    # we got a game-event from other application place. we need
    # forward it to connected and authorized browser clients.
    publishEvent: (gameEvent)=>
        @clients[gameEvent.char]?.sendEvent gameEvent

module.exports = BrowserProxy