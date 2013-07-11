'use strict'

UNITS_PER_METER = 0.01
PI_DIV_180 = Math.PI/180

exports.fromMeters = (meters)-> meters * UNITS_PER_METER
exports.fromKm     = (km)-> UNITS_PER_METER * km * 1000

exports.degreesToRadians = (degrees) -> degrees * PI_DIV_180
exports.radiansToDegree = (radians) -> radians / PI_DIV_180