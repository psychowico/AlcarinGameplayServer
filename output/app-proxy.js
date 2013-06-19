'use strict';
var net;

net = require('net');

exports.init = function(config) {
  var Proxy;

  Proxy = (function() {
    var onconnect;

    function Proxy() {}

    onconnect = function(socket) {};

    Proxy.prototype.connect = function() {};

    return Proxy;

  })();
  return new Proxy();
};
