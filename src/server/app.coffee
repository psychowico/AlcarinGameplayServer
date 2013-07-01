'use strict'

net    = require 'net'

config = require '../config'
EventsBus = require '../events-bus'

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
        @clients.splice ind, 1

class AppClient

    buffer: ''

    constructor: (@proxy, @socket)->
        @socket.on 'data', @on_data
        socket.on 'end', @on_disconnect
        @log 'connected'

    on_disconnect: =>
        @log 'disconnected'
        @proxy.removeClient @

    on_data: (data)=>
        # we need buffering data until we got agreed end of buffer signal (\0)
        _log = 'data received.. '
        subbuffer = data.toString()
        if subbuffer[subbuffer.length - 1] == '\0'
            _log += 'resolving'
            json = JSON.parse @buffer + subbuffer.substr 0, subbuffer.length - 1
            EventsBus.emit 'events.delivery', json
            @buffer = ''
        else
            _log += 'buffering.'
            @buffer += subbuffer
        @log _log

    log: (text)->
        console.log "AppClient: #{text}."

module.exports = new Proxy()