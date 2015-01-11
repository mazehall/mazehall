var authorization, events, manager, modules, secrets, socket;

socket = require('socket.io');

authorization = require('./authorization');

modules = require('../modules');

secrets = require('../secrets');

events = {
  mazehallCoreConfigGetInstalledModules: function() {
    socket = this;
    console.log("[socket:core] %s push modules by components list", this.handshake.address);
    return modules.getModulesByComponents(this.decoded_token.components, function(err, packages) {
      if (err) {
        throw new Error(err);
      }
      return socket.emit("mazehallCoreConfigInstalledModules", packages);
    });
  },
  disconnect: function() {
    return console.log("[socket:core] %s disconnect", this.handshake.address);
  },
  reconnect: function(socket) {
    return console.log("[socket:core] %s reconnection was successful", this.handshake.address);
  },
  error: function(socket) {
    return console.log("[socket:core] %s connection error", this.handshake.address);
  }
};

manager = function(server) {
  var io, _ref;
  if ((secrets != null ? (_ref = secrets.mazehall) != null ? _ref.socket : void 0 : void 0) == null) {
    return console.log("[socket:core] skipped socket init");
  }
  console.log("[socket:core] init socket");
  io = socket(server);
  return io.on('connection', authorization.authOnEvent({
    secret: secrets.mazehall.socket,
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

module.exports = manager;
