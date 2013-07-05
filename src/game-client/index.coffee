'use strict'

###
This module return class that represnt connection with one game webbrowser client.
It is related with one browser tab and one character. Connection must be authenticated
by php session id (related with choosed character player)
###

# requires

cookie        = require 'cookie'
checkSession  = require '../tool/session-checker'
EventsBus     = require '../events-bus'
resolveEvents = require('./game-events-resolver').resolveAll
Character     = require './character.coffee'
log           = require '../logger'

# module code

class GameClient
    sessionId : null
    character : null
    charid    : null
    authorized: false

    constructor: (@proxy, @socket)->
        cookies    = cookie.parse @socket.handshake.headers.cookie
        @sessionId = cookies.alcarin
        @socket.on 'auth', @onAuth
        @socket.on 'disconnect', @onDisconnect

        @log "connected"

    log: (text, type = 'info')->
        log[type] "WebBrowser client '#{@sessionId}': #{text}."

    sendEvent: (gameEvent, need_reset)=>
        if @authorized
            # we need first resolve events before sending it to client
            @character.done (_char)=>
                eventResolving = resolveEvents _char, [gameEvent]
                eventResolving.done (gameEventsPack)=>
                    resolvedGameEvent = gameEventsPack[0]
                    @socket.emit 'game-event', resolvedGameEvent

    resetEvents: (events)=>
        if @authorized
            @character.done (_char)=>
                # we need first resolve events before sending it to client
                eventResolving = resolveEvents _char, events
                eventResolving.done (gameEventsPack)=>
                    @socket.emit 'reset-events', gameEventsPack

    # client is authorized by his session id. we need check that this session id is
    # valid for specific character.
    onAuth: (data)=>
        session = @sessionId
        @character = Character.fromId data.charid
        @charid    = data.charid

        # if we can not fetch character data we can not continue
        @character.fail @manualDisconnect

        sessionChecked = =>
            @authorized = true
            EventsBus.emit 'web-client.authorized', @
            @socket.emit 'authorized'
            @log 'authorized'

        checkSession(session, data.charid).done sessionChecked, @manualDisconnect

    manualDisconnect: (reason)=>
        @authorized = false
        @socket.disconnect()
        @log reason

    onDisconnect: =>
        @log "disconnected"
        EventsBus.emit 'web-client.disconnected', @

# exports

module.exports = GameClient
