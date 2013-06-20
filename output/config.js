var config;

config = function() {
  this.client_port = 8080;
  this.app_port = 8081;
  this.mongo_connection_string = 'mongodb://localhost/alcarin';
  return this.log_level = 1;
};

config.apply(exports);
