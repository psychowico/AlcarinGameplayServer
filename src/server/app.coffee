'use strict'

###
This server listening for connection from php app. For any connection it
generate AppClient object. It used 'net' for communication (tcp protocol, sending json)
###

net       = require 'net'
AppClient = require '../app-client'
config    = require '../config'
EventsBus = require '../events-bus'

class AppProxy

    clients : []

    start: ->
        server = net.createServer().listen config.app_port, '127.0.0.1', ->
            console.log "-- App server ready, listening on #{config.app_port}"
        server.on 'connection', @onAppConnected
        EventsBus.on 'app-client.disconnected', @onAppDisconnected

    onAppConnected: (socket)=>
        @clients.push new AppClient @, socket

    onAppDisconnected: (client)=>
        ind = @clients.indexOf client.socket
        @clients.splice ind, 1

module.exports = AppProxy