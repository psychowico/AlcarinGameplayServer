'use strict'

net  = require 'net'
JsonSocket = require 'json-socket'

exports.init = (config)->
    class Proxy

        constructor: ->
            @clients = []

        on_connect: (socket)=>
            @clients.push new AppClient @, new JsonSocket socket

        connect: ->
            server = net.createServer().listen config.app_port, '127.0.0.1', ->
                    console.log "-- App server ready, listening on #{config.app_port}"
            server.on 'connection', @on_connect

    class AppClient

        constructor: (@proxy, @socket)->
            @socket.on 'message', @on_message
            @log 'connected'

        on_message: (data)=>
            @log 'new data'
            console.log data

        log: (text)->
            console.log "AppClient: #{text}."

    return new Proxy()