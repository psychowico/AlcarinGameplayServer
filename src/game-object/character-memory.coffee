"use strict"

db         = require '../tool/mongo'
Q          = require 'q'
memory     = db.collection('map.chars.memory')

class Memory

    constructor: (@owner)->

    # character: (targetid)->
    #     @_fetch 'char', targetid

    place: (placeid, use_default=true)->
        _default = 'no-named-place' if use_default
        @_fetch 'place', placeid, _default or false

    _fetch: (type, targetid, default_tag)->
        if not db.ObjectId.isValid targetid
            targetid = db.ObjectId targetid

        q = Q.defer()

        args =
            who   : @owner._id
            type  : type
            target: targetid

        remembering = Q.ninvoke memory, 'findOne', args, ['val']
        remembering = remembering.then (result)=>
            if result?
                Q.resolve result.val
            else
                if default_tag == false
                    # can find any suitable name for place
                    Q.resolve false
                else
                    translating = @owner.transl 'static', "#{default_tag}.std"
                    translating.then Q.resolve, -> Q.resolve 'no-tag'
        remembering.done q.resolve, q.reject
        q.promise

module.exports = Memory
