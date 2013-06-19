var io;

io = require('socket.io').listen(8080);

io.sockets.on('connection', function(socket) {
  socket.emit('news', {
    hello: 'world'
  });
  return socket.on('japko', function(data) {
    return console.log('dostalem japko od servera');
  });
});
