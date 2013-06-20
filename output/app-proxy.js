'use strict';
var net;

net = require('net');

exports.init = function(config) {
  var Proxy;

  Proxy = (function() {
    var onconnect;

    function Proxy() {}

    onconnect = function(socket) {
      return console.log('New app client connected.');
    };

    Proxy.prototype.connect = function() {
      return net.createServer(onconnect).listen(config.app_port, '127.0.0.1', function() {
        return console.log("-- App server ready, listening on " + config.app_port);
      });
    };

    return Proxy;

  })();
  return new Proxy();
};
