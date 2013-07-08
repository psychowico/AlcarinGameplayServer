'use strict'

module.exports = (char, arg)->
    return 'arg.resolved' if arg.__base?

module.exports.priority = 100