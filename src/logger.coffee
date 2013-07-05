winston = require 'winston'
module.exports = new winston.Logger
  transports: [
    new winston.transports.Console
        colorize        : true
        # handleExceptions: true
        timestamp       : ->
            date = new Date
            "#{date.getHours()}:#{date.getMinutes()}"
  ]