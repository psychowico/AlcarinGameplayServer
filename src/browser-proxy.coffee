'use strict'

io = require('socket.io')
exports.init = (config)->
    class Proxy
        onconnect = (socket)->
            socket.emit 'news', { hello: 'world' }
            socket.on 'japko', (data)->
                console.log('dostalem japko od servera')

        connect: ->
            @server = io.listen config.client_port
            @server.sockets.on 'connection', onconnect

    return new Proxy()