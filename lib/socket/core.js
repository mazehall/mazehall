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
        var name;
        socket.mazehall = {
          components: socket.handshake.query.components || 'null',
          componentsArray: (socket.handshake.query.components || 'null').split(",")
        };
        if (!socket.mazehall.components) {
          return console.log("[socket:core] connection %s rejected - not a valid mazehall node", socket.handshake.address);
        }
        console.log("[socket:core] %s are connected - components: %s", socket.handshake.address, socket.mazehall.components.toUpperCase());
        for (name in manager.method) {
          socket.on(name, manager.method[name]);
        }
        return socket.join(socket.mazehall.components.toLowerCase());
      });
      console.log("[socket:core] listening on port %d", this.listen);
      return this;
    }
  };

  manager.method.mazehallCoreConfigInstallModule = function(module) {
    var cli, option, source;
    console.log("[socket:core] add new package: ", module.name);
    option = {};
    source = module.name;
    if ((module != null ? module.repository : void 0) && (module != null ? module.type : void 0) === "npm") {
      option.repo = source = module.repository;
    }
    cli = require("./../cli");
    cli.install(source, option, function() {
      var components, newmodules;
      console.log("[socket:" + manager.socket.mazehall.components + "] sync | broadcast install complete");
      components = "ui";
      newmodules = [];
      manager.socket.to(components).emit("mazehallCoreConfigInstalledModules", newmodules);
      return manager.socket.to(components).emit("mazehallCoreConfigAvailableModules", newmodules);
    });
    return this;
  };

  manager.method["mazehallCoreConfigUninstallModule"] = function(module) {
    var cli;
    console.log("[socket:core] remove package: ", module);
    cli = require("./../cli");
    cli.uninstall(module.name, function() {
      var components, newmodules;
      console.log("[socket:" + manager.socket.mazehall.components + "] sync | broadcast remove complete");
      components = "ui";
      newmodules = [];
      manager.socket.to(components).emit("mazehallCoreConfigInstalledModules", newmodules);
      return manager.socket.to(components).emit("mazehallCoreConfigAvailableModules", newmodules);
    });
    return this;
  };

  manager.method.mazehallCoreConfigGetAvailableModules = function() {
    modules = [
      {
        name: 'example-npm-vpopqmail',
        version: '0.0.1',
        repository: '.dummy-repository/example-npm-vpopqmail/',
        type: 'npm'
      }, {
        name: 'example-npm-nginx',
        version: '0.0.1',
        repository: '.dummy-repository/example-npm-nginx/',
        type: 'npm'
      }
    ];
    this.emit("mazehallCoreConfigAvailableModules", modules);
    return this;
  };

  manager.method.mazehallCoreConfigGetInstalledModules = function() {
    console.log("[socket:core] push module list to connectors");
    socket = this;
    socket.emit("mazehallCoreConfigInstalledModules", modules.packages);
    return this;
  };

  manager.method.disconnect = function() {
    console.log("[socket:core] %s disconnect - components: %s", this.handshake.address, this.mazehall.components.toUpperCase());
    this.leave(this.mazehall.components.toLowerCase());
    return this;
  };

  manager.method.reconnect = function(socket) {
    console.log("[socket:core] reconnection was successful");
    return this;
  };

  manager.method.error = function(socket) {
    console.log("[socket:core] connection error");
    return this;
  };

  module.exports = manager;

}).call(this);
