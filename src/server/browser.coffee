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
        EventsBus.on 'events.delivery', @processEventsDelivery

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

    # we got events pack from app server. we need process it and forward it to
    # connected and authorized browser clients.
    processEventsDelivery: (data)=>
        count = 0
        for dataPack in data
            if dataPack.$reset
                for charid in dataPack.$ids
                    count++ if @clients[charid]?
                    @clients[charid]?.resetEvents dataPack.$events
            else
                for charid in dataPack.$ids
                    count++ if @clients[charid]?
                    @clients[charid]?.sendEvent dataPack.$event
        log.info "Forwarding GameEvent struct to #{count} clients."

module.exports = BrowserProxy