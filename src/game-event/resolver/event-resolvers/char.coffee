'use strict'


db         = require '../../../tool/mongo'
Q          = require 'q'
resolveTag = require('../../../tool/tags-resolver').resolveTag

module.exports = (character, arg)->
    character.resolveName {_id: arg.id} if arg.type is 'char'