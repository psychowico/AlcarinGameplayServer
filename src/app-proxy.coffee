'use strict'

net = require('net')
exports.init = (config)->
    class Proxy
        onconnect = (socket)->
            # socket.emit 'news', { hello: 'world' }
            # socket.on 'japko', (data)->
            #     console.log('dostalem japko od servera')

        connect: ->
            # tcp.createServer (socket)->
            #   socket.write 'Echo server\r\n'
            #   socket.pipe socket
            # .listen(config.app_port, '127.0.0.1');

    return new Proxy()