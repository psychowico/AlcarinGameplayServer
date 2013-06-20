'use strict'

net = require 'net'
exports.init = (config)->
    class Proxy
        onconnect = (socket)->
            console.log 'New app client connected.'
            # socket.emit 'news', { hello: 'world' }
            # socket.on 'japko', (data)->
            #     console.log('dostalem japko od servera')

        connect: ->
            net.createServer(onconnect)
                .listen config.app_port, '127.0.0.1', ->
                    console.log "-- App server ready, listening on #{config.app_port}"

    return new Proxy()