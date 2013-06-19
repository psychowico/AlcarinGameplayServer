'use strict';
var io;

io = require('socket.io');

exports.init = function(config) {
  var Proxy;

  Proxy = (function() {
    var onconnect;

    function Proxy() {}

    onconnect = function(socket) {
      socket.emit('news', {
        hello: 'world'
      });
      return socket.on('japko', function(data) {
        return console.log('dostalem japko od servera');
      });
    };

    Proxy.prototype.connect = function() {
      this.server = io.listen(config.client_port);
      return this.server.sockets.on('connection', onconnect);
    };

    return Proxy;

  })();
  return new Proxy();
};
