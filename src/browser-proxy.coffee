'use strict'

io       = require 'socket.io'
cookie   = require 'cookie'

exports.init = (config)->
    check_session = require('./session-checker.coffee').init config
    class Proxy

        constructor: ->
            @clients = []

        connect: ->
            @server = server = io.listen config.client_port, ->
                console.log "-- WebClient server ready, listening on #{config.client_port}"
            server.sockets.on 'connection', @on_client_connect
            server.set 'log level', config.log_level

        on_client_connect: (socket)=>
            @clients.push new GameClient @, socket

        removeClient: (client)=>
            index = @clients.indexOf client
            @clients.splice index, 1

    class GameClient
        @session_id = null
        @authorized = false

        log: (text)->
            console.log "WebBrowser client '#{@session_id}': #{text}."

        constructor: (@proxy, @socket)->
            cookies = cookie.parse @socket.handshake.headers.cookie
            @session_id = cookies.alcarin
            @socket.on 'auth', @on_auth
            @socket.on 'disconnect', @on_disconnect

            @log "connected"

        # client is authorized by his session id. we need check that this session id is
        # valid for specific character.
        on_auth: (data)=>
            session = @session_id
            char = data.charid
            check_session session, char, =>
                @authorized = true
                @log 'authorized'
            , (err)=>
                @authorized = false
                console.error err

        on_disconnect: =>
            @log "disconnected"
            @proxy.removeClient @

    return new Proxy()