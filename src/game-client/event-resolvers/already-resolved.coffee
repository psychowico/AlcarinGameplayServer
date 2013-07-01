'use strict'

module.exports = (char, arg, callback)->
    if arg.__base?
        callback true
    else
        callback()

module.exports.priority = 100