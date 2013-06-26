'use strict'

client_server = require('./server/browser')
client_server.connect()

app_server = require('./server/app')
app_server.connect()