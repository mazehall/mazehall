(function() {
  var components, manager, mazehall, modules, params, socket;

  socket = require("socket.io-client");

  mazehall = require("mazehall");

  modules = require("../modules");

  components = mazehall.components;

  params = {
    query: {
      components: components
    }
  };

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
      console.log("[socket:" + components + "] core server > " + this.socket.io.uri);
      for (name in this.method) {
        manager.socket.on(name, this.method[name]);
      }
      return this;
    }
  };

  manager.method.connect = function(socket) {
    console.log("[socket:" + components + "] connected to core!");
    this.emit("mazehallCoreConfigGetInstalledModules");
    return this;
  };

  manager.method.disconnect = function(message) {
    console.log("[socket:" + components + "] %s: disconnected from core ...reconnect", message);
    return this;
  };

  manager.method.reconnect = function(socket) {
    console.log("[socket:" + components + "] reconnection was successful");
    return this;
  };

  manager.method.reconnect_error = function(error) {
    console.log("[socket:" + components + "] couldn’t reconnect to core | %d: %s", error.description, error.message);
    return this;
  };

  manager.method.error = function(error) {
    console.log("[socket:" + components + "] connection error | %d: %s", error.description, error.message);
    return this;
  };

  manager.method.mazehallCoreConfigInstalledModules = function(data) {
    var index, module, _i, _len;
    if (!Array.isArray(data)) {
      return;
    }
    console.log("[socket:" + components + "] received modules (%d) ", data.length);
    if (data != null) {
      for (index = _i = 0, _len = data.length; _i < _len; index = ++_i) {
        module = data[index];
        console.log("[socket:" + components + "] [%s] %s @%s", index + 1, module.name, module.version);
      }
    }
    modules.synchronize(data);
    return this;
  };

  module.exports = manager;

}).call(this);
