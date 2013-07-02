'use strict'

###
This server listening for webbrowser connection. For any connection it
generate GameClient object. It used socket.io for communication.
###

io         = require 'socket.io'
config     = require '../config'
EventsBus  = require '../events-bus'
GameClient = require '../game-client'

class BrowserProxy
    clients         : {}
    ungroupedClients: []

    start: ->
        @server = server = io.listen config.client_port, ->
            console.log "-- WebClient server ready, listening on #{config.client_port}"
        server.set 'log level', config.log_level
        server.sockets.on 'connection', @onClientConnected

        EventsBus.on 'web-client.disconnected', @onClientDisconnected
        EventsBus.on 'web-client.authorized', @onClientAuthorized
        EventsBus.on 'events.delivery', @processEventsDelivery

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

    # we got events pack from app server. we need process it and forward it to
    # connected and authorized browser clients.
    processEventsDelivery: (data)=>
        for dataPack in data
            if dataPack.$reset
                for charid in dataPack.$ids
                    @clients[charid]?.resetEvents dataPack.$events
            else
                for charid in dataPack.$ids
                    @clients[charid]?.sendEvent dataPack.$event

module.exports = BrowserProxy