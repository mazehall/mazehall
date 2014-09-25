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
      var name, _results;
      if (!this.socket) {
        this.socket = socket("http://" + mazehall.coreSocket + "/socket", params);
      }
      console.log("[socket:" + components + "] core server > " + this.socket.io.uri);
      _results = [];
      for (name in this.method) {
        _results.push(manager.socket.on(name, this.method[name]));
      }
      return _results;
    }
  };

  manager.method.connect = function(socket) {
    console.log("[socket:" + components + "] connected to core!");
    return this.emit("mazehallCoreConfigGetInstalledModules");
  };

  manager.method.disconnect = function(message) {
    return console.log("[socket:" + components + "] %s: disconnected from core ...reconnect", message);
  };

  manager.method.reconnect = function(socket) {
    return console.log("[socket:" + components + "] reconnection was successful");
  };

  manager.method.reconnect_error = function(error) {
    return console.log("[socket:" + components + "] failed to reconnect to core | %d: %s", error.description, error.message);
  };

  manager.method.error = function(error) {
    return console.log("[socket:" + components + "] connection error | %d: %s", error.description, error.message);
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
    return modules.synchronize(data);
  };

  module.exports = manager;

}).call(this);
