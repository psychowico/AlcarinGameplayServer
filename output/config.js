var config;

config = function() {
  this.client_port = 8080;
  return this.app_port = 8081;
};

config.apply(exports);
