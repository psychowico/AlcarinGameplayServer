'use strict';
var cookie, io,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

io = require('socket.io');

cookie = require('cookie');

exports.init = function(config) {
  var GameClient, Proxy, check_session;

  check_session = require('./session-checker.js').init(config);
  Proxy = (function() {
    function Proxy() {
      this.removeClient = __bind(this.removeClient, this);
      this.on_client_connect = __bind(this.on_client_connect, this);      this.clients = [];
    }

    Proxy.prototype.connect = function() {
      var server;

      this.server = server = io.listen(config.client_port, function() {
        return console.log("-- WebClient server ready, listening on " + config.client_port);
      });
      server.sockets.on('connection', this.on_client_connect);
      return server.set('log level', config.log_level);
    };

    Proxy.prototype.on_client_connect = function(socket) {
      return this.clients.push(new GameClient(this, socket));
    };

    Proxy.prototype.removeClient = function(client) {
      var index;

      index = this.clients.indexOf(client);
      return this.clients.splice(index, 1);
    };

    return Proxy;

  })();
  GameClient = (function() {
    GameClient.session_id = null;

    GameClient.authorized = false;

    function GameClient(proxy, socket) {
      var cookies;

      this.proxy = proxy;
      this.socket = socket;
      this.on_disconnect = __bind(this.on_disconnect, this);
      this.on_auth = __bind(this.on_auth, this);
      cookies = cookie.parse(this.socket.handshake.headers.cookie);
      this.session_id = cookies.alcarin;
      this.socket.on('auth', this.on_auth);
      this.socket.on('disconnect', this.on_disconnect);
      console.log("WebBrowser client '" + this.session_id + "' connected.");
    }

    GameClient.prototype.on_auth = function(data) {
      var char, session,
        _this = this;

      session = this.session_id;
      char = data.charid;
      return check_session(session, char, function() {
        _this.authorized = true;
        return console.log('Web client authorized.');
      }, function(err) {
        _this.authorized = false;
        return console.error(err);
      });
    };

    GameClient.prototype.on_disconnect = function() {
      console.log("WebBrowser client '" + this.session_id + "' disconnected.");
      return this.proxy.removeClient(this);
    };

    return GameClient;

  })();
  return new Proxy();
};
