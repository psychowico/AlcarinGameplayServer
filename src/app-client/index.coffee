'use strict'

###
This module return class that represnt connection with one game php app client.
###

EventsBus     = require '../events-bus'
log           = require '../logger'

class AppClient
    buffer: ''

    constructor: (@proxy, @socket)->
        @socket.on 'data', @onData
        @socket.on 'end', @onDisconnect
        @log 'connected'

    log: (text, type = 'info')->
        log[type] "AppClient: #{text}."

    onDisconnect: =>
        @log 'disconnected'
        EventsBus.emit 'app-client.disconnected', @

    # we buffering data until we got agreed end of buffer signal (\0).
    # then we parse buffer as json object and generate 'events.delivery'
    # global event
    onData: (data)=>

        logMsg = 'data received.. '
        subbuffer = data.toString()

        isEndOfStream = subbuffer[subbuffer.length - 1] == '\0'
        if isEndOfStream
            logMsg += 'resolving'
            json = JSON.parse @buffer + subbuffer.substr 0, subbuffer.length - 1
            EventsBus.emit 'events.delivery', json
            @buffer = ''
        else
            logMsg += 'buffering.'
            @buffer += subbuffer
        @log logMsg

module.exports = AppClient