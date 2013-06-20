'use strict'

io       = require 'socket.io'
cookie   = require 'cookie'

#console.log mongo

exports.init = (config)->
    check_session = require('./session-checker.js').init config
    class Proxy
        @session_id = null
        @authorized = false

        # client is authorized by his session id. we need check that this session id is
        # valid for specific character.
        on_auth  = (data)=>
            session = @session_id
            char = data.charid
            check_session session, char, =>
                @authorized = true
                console.log 'Web client authorized.'
            , (err)->
                @authorized = false
                console.error err


        on_connect = (socket)=>
            console.log 'WebBrowser client connected.'
            cookies = cookie.parse socket.handshake.headers.cookie
            @session_id = cookies.alcarin
            socket.on 'auth', on_auth

        connect: ->
            @server = io.listen config.client_port, ->
                console.log "-- WebClient server ready, listening on #{config.client_port}"
            @server.sockets.on 'connection', on_connect

    return new Proxy()