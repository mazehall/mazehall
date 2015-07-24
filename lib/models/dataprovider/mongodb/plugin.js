var _r, connection, mazecli, plugin;

connection = require("./connection");

mazecli = require("./../../../cli");

_r = require("kefir");

plugin = {
  getCollection: function() {
    return connection.getCollection("plugins");
  },
  tailCursor: function() {
    var plugins;
    plugins = this.getCollection();
    return plugins.find({}, {}, {
      tailable: true,
      timeout: false
    });
  },
  save: function(dataset) {
    var callback, plugins;
    callback = arguments[arguments.length - 1];
    plugins = this.getCollection();
    return plugins.insert(dataset, function() {
      return typeof callback === "function" ? callback.apply(null, arguments) : void 0;
    });
  },
  findAll: function() {
    var callback, plugins;
    callback = arguments[arguments.length - 1];
    plugins = this.getCollection();
    return plugins.find().sort({
      _id: -1
    }).limit(1).toArray(function(err, doc) {
      var ref;
      if ((ref = doc[0]) != null ? ref._id : void 0) {
        delete doc[0]._id;
      }
      return typeof callback === "function" ? callback(err, doc) : void 0;
    });
  },
  initSync: function() {
    var stream;
    stream = _r.fromEvents(this.tailCursor(), "data");
    return stream.onValue(function() {
      return mazecli.pluginSync();
    });
  }
};

module.exports = function(options) {
  connection.createDbConnection(options);
  return plugin;
};
