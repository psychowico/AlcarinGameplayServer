'use strict'


# remember that day have 94 hours and events is related
# with character position on the world. when character is on 0 degress
# position (world is flat, 0 degress is vector (1, 0) in game units)
# it means that on 0 o'clock he has exacly midday, on 48 o'clock -
# middle of the night.
# when he move somewhere, hour are moved related to his position, for sample,
# when he are on 90 degress (0, 1):
# offset = (90 / 360) * 96
# and we add offset to all times

Q          = require 'q'
GameTime   = require('../tool/gametime').GameTime

# later text should be changed to tags
events = [
    {
        from: 0
        to: 96
        text: 'Na świecie panuje jeszcze nieokreślona pora dnia, wszystko zdaje się stać w miejscu bez celu.'
    }
    {
        from: 0
        to: 24
        text: 'A może jest popołudnie?'
    }
    {
        from: 24
        to: 72
        text: 'Chociaż chyba jest noc.'
    }
    {
        from: 72
        to: 96
        text: 'Chociaż chyba świta.'
    }
]

class TimeOfDay


    @description: (time, location)->
        gametime  = new GameTime time
        localhour = gametime.localhour location

        descr = ''
        for val in events
            if localhour >= val.from and localhour <= val.to
                descr += ' ' + val.text

        Q.resolve descr

module.exports = TimeOfDay