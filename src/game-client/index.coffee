'use strict'

###
This module return class that represnt connection with one game webbrowser client.
It is related with one browser tab and one character. Connection must be authenticated
by php session id (related with choosed character player)
###

# requires

cookie        = require 'cookie'
checkSession  = require './session-checker'
resolveEvents = require('../game-event/resolver').resolveAll
log           = require '../logger'

EventsBus           = require '../events-bus'
Character           = require '../game-object/character'
GameEventsResponder = require('../game-event/responder')

# module code

class GameClient
    sessionId : null
    # character : null
    charid    : null
    authorized: false
    responder : null

    constructor: (@proxy, @socket)->
        cookies    = cookie.parse @socket.handshake.headers.cookie
        @sessionId = cookies.alcarin

        @socket.on 'auth', @onAuth
        @socket.on 'disconnect', @onDisconnect
        @socket.on '*', @onClientEvent

        @responder = new GameEventsResponder @
        @log "connected"

    log: (text, type = 'info')->
        log[type] "WebBrowser client '#{@sessionId}': #{text}."

    resolvingCharacter: =>
        Character.fromId @charid

    # server can directly sent to online clients events by this method
    sendEvent: (gameEvent, need_reset)=>
        if @authorized
            # we need first resolve events before sending it to client
            @resolvingCharacter().done (_char)=>
                eventResolving = resolveEvents _char, [gameEvent]
                eventResolving.done (gameEventsPack)=>
                    resolvedGameEvent = gameEventsPack[0]
                    @socket.emit 'game-event.add', resolvedGameEvent

    onClientEvent: (ev)=>
        return false if not @authorized
        @responder.respond ev.name, ev.args if @responder.has ev.name

    authorize: =>
        @authorized = true
        EventsBus.emit 'web-client.authorized', @
        @socket.emit 'client.authorized'
        @log 'authorized'


    # client is authorized by his session id. we need check that this session id is
    # valid for specific character.
    onAuth: (data)=>
        return false if @authorized
        session = @sessionId
        @charid    = data.charid

        # if we can not fetch character data we can not continue
        # @character.fail @manualDisconnect
        checkSession(session, data.charid).done @authorize, @manualDisconnect

    manualDisconnect: (reason)=>
        @authorized = false
        @socket.disconnect()
        @log reason

    onDisconnect: =>
        @log "disconnected"
        EventsBus.emit 'web-client.disconnected', @

# exports

module.exports = GameClient
