"use strict"

db         = require '../tool/mongo'
Q          = require 'q'
memory     = db.collection('map.chars.memory')

class Memory

    constructor: (@owner)->

    character: (targetid)->
        @_fetch 'char', targetid

    place: (placeid)->
        @_fetch 'place', placeid

    _fetch: (type, targetid)->
        if not db.ObjectId.isValid targetid
            targetid = db.ObjectId targetid

        q = Q.defer()

        args =
            who   : @owner._id
            type  : type
            target: targetid

        remembering = Q.ninvoke memory, 'findOne', args, ['val']
        remembering = remembering.then (result)->
            if result? then Q.resolve result.val else Q.reject()
        remembering.done q.resolve, q.reject
        q.promise
