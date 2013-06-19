io = require('socket.io').listen 8080

io.sockets.on 'connection', (socket)->
  socket.emit 'news', { hello: 'world' }
  socket.on 'japko', (data)->
    console.log('dostalem japko od servera')