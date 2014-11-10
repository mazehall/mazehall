(function() {
  var components, events, io, jwt, manager, modules, secrets, tokenData;

  jwt = require("jsonwebtoken");

  io = require("socket.io-client");

  modules = require("../modules");

  secrets = require('../secrets');

  events = [];

  components = '';

  tokenData = {
    components: components
  };

  manager = function(coreSocket, initComponents) {
    var name, socket, _ref, _results;
    components = initComponents;
    if ((secrets != null ? (_ref = secrets.mazehall) != null ? _ref.socket : void 0 : void 0) == null) {
      return console.log("[socket:" + components + "] skipped socket init");
    }
    console.log("[socket:" + components + "] init socket");
    socket = io("" + coreSocket);
    console.log("[socket:" + components + "] core server > " + socket.io.uri);
    _results = [];
    for (name in events) {
      _results.push(socket.on(name, events[name]));
    }
    return _results;
  };

  events.connect = function(socket) {
    var token;
    console.log("[socket:" + components + "] connected to core!");
    token = jwt.sign(tokenData, secrets.mazehall.socket, {
      expiresInMinutes: 60
    });
    console.log("[socket:" + components + "] authentication with core...");
    return this.emit("authenticate", {
      "token": "token",
      token: token
    });
  };

  events.authenticated = function() {
    console.log("[socket:" + components + "] authenticated on core");
    return this.emit("mazehallCoreConfigGetInstalledModules");
  };

  events.disconnect = function(message) {
    return console.log("[socket:" + components + "] %s: disconnected from core ...reconnect", message);
  };

  events.reconnect = function(socket) {
    return console.log("[socket:" + components + "] reconnection was successful");
  };

  events.reconnect_error = function(error) {
    return console.log("[socket:" + components + "] failed to reconnect to core | %d: %s", error.description, error.message);
  };

  events.error = function(error) {
    return console.log("[socket:" + components + "] connection error | %d: %s", error.description, error.message);
  };

  events.mazehallCoreConfigInstalledModules = function(data) {
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
