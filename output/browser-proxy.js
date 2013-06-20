'use strict';
var cookie, io;

io = require('socket.io');

cookie = require('cookie');

exports.init = function(config) {
  var Proxy, check_session;

  check_session = require('./session-checker.js').init(config);
  Proxy = (function() {
    var on_auth, on_connect,
      _this = this;

    function Proxy() {}

    Proxy.session_id = null;

    Proxy.authorized = false;

    on_auth = function(data) {
      var char, session;

      session = Proxy.session_id;
      char = data.charid;
      return check_session(session, char, function() {
        Proxy.authorized = true;
        return console.log('Web client authorized.');
      }, function(err) {
        this.authorized = false;
        return console.error(err);
      });
    };

    on_connect = function(socket) {
      var cookies;

      console.log('WebBrowser client connected.');
      cookies = cookie.parse(socket.handshake.headers.cookie);
      Proxy.session_id = cookies.alcarin;
      return socket.on('auth', on_auth);
    };

    Proxy.prototype.connect = function() {
      this.server = io.listen(config.client_port, function() {
        return console.log("-- WebClient server ready, listening on " + config.client_port);
      });
      return this.server.sockets.on('connection', on_connect);
    };

    return Proxy;

  }).call(this);
  return new Proxy();
};
