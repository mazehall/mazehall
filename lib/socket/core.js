(function() {
  var authorization, events, manager, mazehall, modules, socket;

  socket = require('socket.io');

  mazehall = require('mazehall');

  authorization = require('./authorization');

  modules = require('../modules');

  events = [];

  manager = function() {
    var io;
    io = socket(mazehall.server);
    return io.on('connection', authorization.authOnEvent({
      secret: 'your secret or public key',
      timeout: 15000
    }, function(err, socket) {
      var name;
      if (err) {
        return socket.disconnect(err);
      }
      if (!socket.decoded_token.components) {
        return socket.disconnect('no components supplied');
      }
      if (!Object.prototype.toString.call(socket.decoded_token.components !== '[object Array]')) {
        return socket.disconnect('no components supplied');
      }
      for (name in events) {
        socket.on(name, events[name]);
      }
      return socket.emit("authenticated");
    }));
  };

  events.mazehallCoreConfigGetInstalledModules = function() {
    socket = this;
    console.log("[socket:core] %s push modules by components list", this.handshake.address);
    return modules.getModulesByComponents(this.decoded_token.components, function(err, packages) {
      if (err) {
        throw new Error(err);
      }
      return socket.emit("mazehallCoreConfigInstalledModules", packages);
    });
  };

  events.disconnect = function() {
    return console.log("[socket:core] %s disconnect", this.handshake.address);
  };

  events.reconnect = function(socket) {
    return console.log("[socket:core] %s reconnection was successful", this.handshake.address);
  };

  events.error = function(socket) {
    return console.log("[socket:core] %s connection error", this.handshake.address);
  };

  module.exports = manager;

}).call(this);
