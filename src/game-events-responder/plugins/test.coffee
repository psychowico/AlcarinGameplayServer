'use strict'

onTestEvent = (socket, character)->
    socket.emit 'nnn', character.name

module.exports =
    'test-event': onTestEvent