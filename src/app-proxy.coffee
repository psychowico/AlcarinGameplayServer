'use strict'

net  = require 'net'

exports.init = (EventsBus, config)->
    class Proxy

        constructor: ->
            @clients = []

        on_connect: (socket)=>
            @clients.push new AppClient @, socket

        connect: ->
            server = net.createServer().listen config.app_port, '127.0.0.1', ->
                    console.log "-- App server ready, listening on #{config.app_port}"
            server.on 'connection', @on_connect

    class AppClient

        constructor: (@proxy, @socket)->
            @socket.on 'data', @on_data
            @log 'connected'

        on_data: (data)=>
            @log 'Data recived.'
            json = data.toString()
            EventsBus.emit 'events.delivery', JSON.parse json

        log: (text)->
            console.log "AppClient: #{text}."

    return new Proxy()