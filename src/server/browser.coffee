'use strict'

io       = require 'socket.io'
cookie   = require 'cookie'

config    = require '../config'
EventsBus = require '../EventsBus'

check_session = require('../tool/session-checker').check

class Proxy

    constructor: ->
        @clients = {}
        @__ungrouped = []
        EventsBus.on 'events.delivery', @on_events_delivery

    on_events_delivery: (events)=>
        # for now it are translated event, in speaker
        # language - but our goal is getting only tagid's
        # and translate them for specific client
        for e in events
            ev = e['event']
            for charid in e.ids
                @clients[charid]?.send_event ev

    connect: ->
        @server = server = io.listen config.client_port, ->
            console.log "-- WebClient server ready, listening on #{config.client_port}"
        server.sockets.on 'connection', @on_client_connect
        server.set 'log level', config.log_level

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

class GameClient
    @session_id = null
    @authorized = false
    @charid     = null

    log: (text)->
        console.log "WebBrowser client '#{@session_id}': #{text}."

    constructor: (@proxy, @socket)->
        cookies = cookie.parse @socket.handshake.headers.cookie
        @session_id = cookies.alcarin
        @socket.on 'auth', @on_auth
        @socket.on 'disconnect', @on_disconnect

        @log "connected"

    send_event: (ev)=>
        @socket.emit 'game-event', ev if @authorized

    # client is authorized by his session id. we need check that this session id is
    # valid for specific character.
    on_auth: (data)=>
        session = @session_id
        @charid  = data.charid
        check_session session, @charid, =>
            @authorized = true
            @proxy.authorizeClient @
            @log 'authorized'
        , (err)=>
            @authorized = false
            console.error err

    on_disconnect: =>
        @log "disconnected"
        @proxy.removeClient @

module.exports = new Proxy()