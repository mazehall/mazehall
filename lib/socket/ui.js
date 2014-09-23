(function() {
  var manager, mazehall, params, socket;

  mazehall = require("mazehall");

  params = {
    query: {
      mazehall_COMPONENT: mazehall.component
    }
  };

  socket = require("socket.io-client");

  manager = {
    socket: null,
    method: [],
    finish: function() {
      return delete this.socket;
    },
    start: function() {
      var name;
      if (!this.socket) {
        this.socket = socket("http://" + mazehall.coreSocket + "/socket", params);
      }
      console.log("[socket:ui] core server > " + this.socket.io.uri);
      for (name in this.method) {
        manager.socket.on(name, this.method[name]);
      }
      return this;
    }
  };

  manager.method.connect = function(socket) {
    console.log("[socket:ui] connected to core!");
    this.emit("mazehallCoreConfigGetInstalledModules");
    return this;
  };

  manager.method.disconnect = function(message) {
    console.log("[socket:ui] %s: disconnected from core ...reconnect", message);
    return this;
  };

  manager.method.reconnect = function(socket) {
    console.log("[socket:ui] reconnection was successful");
    return this;
  };

  manager.method.reconnect_error = function(error) {
    console.log("[socket:ui] couldn’t reconnect to core | %d: %s", error.description, error.message);
    return this;
  };

  manager.method.error = function(error) {
    console.log("[socket:ui] connection error | %d: %s", error.description, error.message);
    return this;
  };

  manager.method.mazehallCoreConfigInstalledModules = function(data) {
    var index, module, modules, _i, _len;
    if (!Array.isArray(data)) {
      return;
    }
    console.log("[socket:ui] received modules (%d) ", data.length);
    if (data != null) {
      for (index = _i = 0, _len = data.length; _i < _len; index = ++_i) {
        module = data[index];
        console.log("[socket:ui] [%s] %s @%s", index + 1, module.name, module.version);
      }
    }
    modules = require("../modules");
    modules.synchronize(data);
    return this;
  };

  module.exports = manager;

}).call(this);
