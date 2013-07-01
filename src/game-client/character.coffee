db = require '../tool/mongo'

module.exports =
class Character
    constructor: (@id)->
        # fetch character data and extend this object
        db.collection('map.chars').findOne {'_id': db.ObjectId @id}, (err, result)=>
            @[key] = prop for key, prop of result