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

        removeClient: (client)=>
            ind = @clients.indexOf client.socket
            @clients.slice ind, 1

    class AppClient

        constructor: (@proxy, @socket)->
            @socket.on 'data', @on_data
            socket.on 'end', @on_disconnect
            @log 'connected'

        on_disconnect: =>
            @log 'disconnected'
            @proxy.removeClient @

        on_data: (data)=>
            @log 'data recived'
            json = data.toString()
            EventsBus.emit 'events.delivery', JSON.parse json

        log: (text)->
            console.log "AppClient: #{text}."

    return new Proxy()