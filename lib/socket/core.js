(function() {
  var manager, mazehall, modules, socket;

  mazehall = require("mazehall");

  socket = require("socket.io");

  modules = require("../modules");

  manager = {
    socket: null,
    method: [],
    finish: function() {
      return delete this.socket;
    },
    start: function(port) {
      this.listen = port || 3001;
      if (this.socket == null) {
        this.socket = socket.listen(this.listen).of("/socket");
      }
      this.socket.on("connection", function(socket) {
        var name, _results;
        socket.mazehall = {
          components: socket.handshake.query.components || 'null'
        };
        if (!socket.mazehall.components) {
          return console.log("[socket:core] connection %s rejected - not a valid mazehall node", socket.handshake.address);
        }
        console.log("[socket:core] %s is connected - components: %s", socket.handshake.address, socket.mazehall.components.toUpperCase());
        _results = [];
        for (name in manager.method) {
          _results.push(socket.on(name, manager.method[name]));
        }
        return _results;
      });
      return console.log("[socket:core] listening on port %d", this.listen);
    }
  };

  manager.method.mazehallCoreConfigGetInstalledModules = function() {
    var components;
    console.log("[socket:core] push module list to connectors");
    socket = this;
    components = this.mazehall.components.split(",");
    return modules.getModulesByComponents(components, function(err, packages) {
      if (err) {
        throw new Error(err);
      }
      return socket.emit("mazehallCoreConfigInstalledModules", packages);
    });
  };

  manager.method.disconnect = function() {
    return console.log("[socket:core] %s disconnect - components: %s", this.handshake.address, this.mazehall.components.toUpperCase());
  };

  manager.method.reconnect = function(socket) {
    return console.log("[socket:core] reconnection was successful");
  };

  manager.method.error = function(socket) {
    return console.log("[socket:core] connection error");
  };

  module.exports = manager;

}).call(this);
