'use strict'

io       = require 'socket.io'

config    = require '../config'
EventsBus = require '../events-bus'
GameClient = require '../game-client'

class Proxy

    constructor: ->
        @clients = {}
        @__ungrouped = []
        EventsBus.on 'events.delivery', @on_events_delivery
        EventsBus.on 'web-client-disconnected', @removeClient
        EventsBus.on 'web-client.authorized', @authorizeClient

    on_events_delivery: (data_arr)=>
        for data in data_arr
            if data.$reset
                for charid in data.$ids
                    @clients[charid]?.reset_events data.$events
            else
                for charid in data.$ids
                    @clients[charid]?.send_event data.$event

    connect: ->
        @server = server = io.listen config.client_port, ->
            console.log "-- WebClient server ready, listening on #{config.client_port}"
        server.set 'log level', config.log_level
        server.sockets.on 'connection', @on_client_connect

    on_client_connect: (socket)=>
        @__ungrouped.push new GameClient @, socket

    authorizeClient: (client)=>
        index = @__ungrouped.indexOf client
        @__ungrouped.splice index, 1
        @clients[client.charid] = client

    removeClient: (client)=>
        id = client.charid
        if id?
            delete @clients[client.charid]
        else
            index = @__ungrouped.indexOf client
            @__ungrouped.splice index, 1

module.exports = new Proxy()