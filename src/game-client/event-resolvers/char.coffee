'use strict'

db = require '../../tool/mongo'

# character can be named in 2 ways.
# first, if character watch himself, he see his original, given by player, name.
# if event viewing character remember this character it's name is resolved
# to name stored in character memory.
# in other case, we render static translated character name, related to his age.
module.exports = (char, arg, callback)->
    result = undefined
    if arg.type is 'char'
        callback char.name if char.id is arg.id
        # db.collection('map.chars.memory').findOne
        #     who   : char.id
        #     type  : 'char'
        #     target: arg.id
        # , (err, result)->
        #     result
    callback result