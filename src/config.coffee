config = ->
    # web browser will fetch for events on this
    @client_port = 8080
    # php server will push events on this port, by using http protocol
    @app_port = 8081

config.apply exports