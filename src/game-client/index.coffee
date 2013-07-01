'use strict'

cookie        = require 'cookie'
check_session = require('../tool/session-checker').check
EventsBus     = require '../events-bus'
Character     = require './character.coffee'
resolveEvents  = require './game-event-resolver'

module.exports =
class GameClient
    session_id: null
    authorized: false
    character : null
    charid : null

    send_event: (ev, need_reset)=>
        if @authorized
            # we need first resolve events before sending it to client
            resolveEvents @character, [ev], (ev)=>
                @socket.emit 'game-event', ev[0]

    reset_events: (events)=>
        if @authorized
            # we need first resolve events before sending it to client
            resolveEvents @character, events, (events)=>
                @socket.emit 'reset-events', events


    # client is authorized by his session id. we need check that this session id is
    # valid for specific character.
    on_auth: (data)=>
        session = @session_id
        @character = new Character data.charid
        @charid    = data.charid
        check_session session, data.charid, =>
            @authorized = true
            EventsBus.emit 'web-client.authorized', @
            @socket.emit 'authorized'
            @log 'authorized'
        , (err)=>
            @authorized = false
            console.error err

    on_disconnect: =>
        @log "disconnected"
        EventsBus.emit 'web-client.disconnected', @

    log: (text)->
        console.log "WebBrowser client '#{@session_id}': #{text}."

    constructor: (@proxy, @socket)->
        cookies = cookie.parse @socket.handshake.headers.cookie
        @session_id = cookies.alcarin
        @socket.on 'auth', @on_auth
        @socket.on 'disconnect', @on_disconnect

        @log "connected"
