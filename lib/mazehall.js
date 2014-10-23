(function() {
  var aggregate, mazehall, modules, runCore, runNonCore, socket;

  socket = require("socket.io");

  modules = require('./modules');

  aggregate = require("./aggregate");

  mazehall = {
    port: process.env.PORT || 3000,
    components: (process.env.MAZEHALL_COMPONENTS || 'core').split(","),
    coreSocket: process.env.MAZEHALL_CORE_SOCKET || 'http://127.0.0.1:3000'
  };

  mazehall.serve = function(callback) {
    if ((mazehall.components.indexOf("core")) >= 0) {
      return runCore(callback);
    }
    return runNonCore(callback);
  };

  runCore = function(callback) {
    return require('./core')(function(err, app, db) {
      var server;
      if (err) {
        throw err;
      }
      mazehall.app = app;
      return server = app.listen(mazehall.port, function() {
        console.log("Mazehall core listening on port " + (server.address().port));
        mazehall.server = server;
        require('./socket/core')();
        if (callback) {
          return callback(err, app);
        }
      });
    });
  };

  runNonCore = function(callback) {
    return require('./nonCore')(function(err, app) {
      var server;
      if (err) {
        throw err;
      }
      mazehall.app = app;
      return server = app.listen(mazehall.port, function() {
        console.log("Mazehall " + mazehall.components + " listening on port " + (server.address().port));
        mazehall.server = server;
        require('./socket/nonCore')();
        if (callback) {
          return callback(err, app);
        }
      });
    });
  };

  module.exports = mazehall;

}).call(this);
