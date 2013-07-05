log = require './logger'

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

config.apply exports

log.info 'initalized configuration..'