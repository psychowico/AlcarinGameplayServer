'use strict'

db = require './mongo'

class SessionChecker
    fields:
        lifetime: 1
        modified: 1
        player  : 1

    _check_permission: (doc, charid, callback)->
        charid = db.ObjectId charid
        modified = doc.modified.getTime() / 1000
        now = new Date()
        if modified + parseInt doc.lifetime < (now.getTime() / 1000)
            callback null, false
        else
            # this is active session. we need be sure
            # that requested character belong to session owner
            params =
                _id: doc.player
                chars: charid
            db.collection('users').count params, (err, size)-> callback err, size > 0

    check: (sessionid, charid, callback, error_callback)=>
        query = {_id: sessionid, name: 'alcarin'}
        db.collection('app.sessions').findOne query, @fields, (err, session)=>
            error_callback err if err
            if session?
                @_check_permission session, charid, (err, result)->
                    if err
                        error_callback err
                    else if result
                        # success!
                        callback()
                    else
                        error_callback 'Session expired.'
            else
                error_callback 'Specific session not exists. Failed access.'

module.exports = new SessionChecker()