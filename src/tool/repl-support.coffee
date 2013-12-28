'use strict'

###
When we active setHook() method of this module, we can turning on/off
REPL system by Alt+P keyboard shortcut
###

repl             = require 'repl'
keypress         = require 'keypress'
tty              = require 'tty'
log              = require '../logger'

replInstance = null

exitRepl = ->
    action = replInstance.commands['.exit'].action
    action.apply replInstance
    replInstance = null
    restoreHook()

toggle = ->
    log && log.info if replInstance? then 'Deactive REPL..' else 'Activate REPL..'

    if replInstance? then exitRepl() else replInstance = repl.start '> '
    active = not active

restoreHook = ->
    process.stdin.setRawMode true if process.stdin.setRawMode
    process.stdin.resume()

setHook = ->
    keypress process.stdin

    process.stdin.setRawMode true if process.stdin.setRawMode
    process.stdin.resume()

    process.stdin.on 'keypress', (ch, key)->
        if key
            process.exit()  if key.ctrl and key.name == 'c'
            toggle() if key if key.meta and key.name == 'p'

exports.setHook    = setHook
