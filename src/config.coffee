log  = require './logger'
unit = require './tool/unit-converter'

config = ->
    # web browser will fetch for events on this
    @client_port = 8080
    # php server will push events on this port, by using http protocol.
    # this port shouldn't be available publicly
    @app_port = 8081
    # mongo connection string
    @mongo_connection_string = 'mongodb://localhost/alcarin'
    # socket.io log level
    @log_level = 1 # 1 - least

    @game =
        character:
            'day-view-radius': unit.fromMeters 200

config.apply exports

log.info 'initalized configuration..'