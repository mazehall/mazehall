(function() {
  var Secrets, path, utils;

  path = require('path');

  utils = require('./utils');

  Secrets = function() {
    var environment;
    environment = process.env.MAZEHALL_ENVIRONMENT || 'production';
    path = path.join(process.cwd(), 'secrets', environment + '.json');
    try {
      return require(path);
    } catch (_error) {
      return {};
    }
  };

  module.exports = new Secrets();

}).call(this);
