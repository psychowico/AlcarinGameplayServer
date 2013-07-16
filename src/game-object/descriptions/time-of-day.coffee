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

Q    = require 'q'
Time = require('../../tool/gametime')

# later text should be changed to tags
events = {
    day    : 'Cóż za piękny dzionek.',
    evening: 'Zaraz będzie ciemno!',
    night  : 'Ciemno wszędzie, głucho wszędzie..',
    morning: 'Z jutrzenką wraca nadzieja.',
}

TimeOfDay = ->
    Time.GameTime().then (gametime)->
        whatTime = gametime.lighting().timeofday
        return events[whatTime] or '<NODESCR>'

module.exports = TimeOfDay