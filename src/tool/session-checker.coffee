'use strict'

###
providing method that from checking that specfic character belong to
specific session id player. returing Q promise.
###

db = require './mongo'
Q  = require 'q'

FIELDS =
    lifetime: 1
    modified: 1
    player  : 1

checkPermission = (doc, charid)->
    deferred = Q.defer()

    charid   = db.ObjectId charid
    modified = doc.modified.getTime() / 1000
    now      = new Date()
    sessionExpired = modified + parseInt doc.lifetime < (now.getTime() / 1000)
    if sessionExpired
        deferred.reject 'Session expired.'
    else
        params =
            _id: doc.player
            chars: charid
        processQuery = Q.ninvoke db.collection('users'), 'count', params
        processQuery.fail deferred.reject

        processQuery.then (size)->
            charBelongToRelPlayer = size > 0
            if charBelongToRelPlayer
                deferred.resolve()
            else deferred.reject 'Char not belong to session related player.'

    deferred.promise

check = (sessionid, charid)=>
    deffered = Q.defer()
    query = {_id: sessionid, name: 'alcarin'}
    db.collection('app.sessions').findOne query, FIELDS, (err, session)=>
        if err then return deffered.reject err
        if session?
            checkPermission(session, charid).then deffered.resolve, deffered.reject
        else
            deffered.reject 'Specific session not exists. Failed access.'
    deffered.promise

module.exports = check