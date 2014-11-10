(function() {
  var aggregate, app, express, mazehall, modules, runCore, runNonCore, socket;

  socket = require('socket.io');

  express = require('express');

  modules = require('./modules');

  aggregate = require("./aggregate");

  app = express();

  mazehall = {
    port: process.env.PORT || 3000,
    components: (process.env.MAZEHALL_COMPONENTS || 'core').split(","),
    coreSocket: process.env.MAZEHALL_CORE_SOCKET || 'http://127.0.0.1:3000',
    app: app,
    serve: function(callback) {
      if ((mazehall.components.indexOf("core")) >= 0) {
        return runCore(callback);
      } else {
        return runNonCore(callback);
      }
    }
  };

  runCore = function(callback) {
    var bootstrap;
    bootstrap = require('./core');
    return bootstrap(app, function(err) {
      var server;
      if (err && callback) {
        return callback(err);
      }
      if (err) {
        throw err;
      }
      return server = app.listen(mazehall.port, function() {
        console.log("Mazehall core listening on port " + (server.address().port));
        mazehall.server = server;
        require('./socket/core')(server);
        if (callback) {
          return callback(null, app);
        }
      });
    });
  };

  runNonCore = function(callback) {
    var bootstrap;
    bootstrap = require('./nonCore');
    return bootstrap(app, mazehall.components, function(err) {
      var server;
      if (err && callback) {
        return callback(err);
      }
      if (err) {
        throw err;
      }
      return server = app.listen(mazehall.port, function() {
        console.log("Mazehall " + mazehall.components + " listening on port " + (server.address().port));
        mazehall.server = server;
        require('./socket/nonCore')(mazehall.coreSocket, mazehall.components);
        if (callback) {
          return callback(null, app);
        }
      });
    });
  };

  module.exports = mazehall;

}).call(this);
