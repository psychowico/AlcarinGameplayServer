var config;

config = function() {
  this.client_port = 8080;
  this.app_port = 8081;
  return this.mongo_connection_string = 'mongodb://localhost/alcarin';
};

config.apply(exports);
