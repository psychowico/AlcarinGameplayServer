'use strict'

UNITS_PER_METER = 0.01

exports.fromMeters = (meters)-> meters * UNITS_PER_METER
exports.fromKm     = (km)-> UNITS_PER_METER * km * 1000
