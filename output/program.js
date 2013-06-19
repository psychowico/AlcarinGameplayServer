'use strict';
var app_server, client_server, config;

config = require('./config.js');

client_server = require('./browser-proxy.js').init(config);

client_server.connect();

app_server = require('./app-proxy.js').init(config);

app_server.connect();
