var mongodb, mongojs;

mongojs = require("mongojs");

mongodb = {
  collection: function() {
    return this.db.collection("plugins");
  },
  tailCursor: function() {
    var plugins;
    plugins = this.collection();
    return plugins.find({}, {}, {
      tailable: true,
      timeout: false
    });
  },
  save: function(dataset) {
    var callback, plugins;
    callback = arguments[arguments.length - 1];
    plugins = this.collection();
    return plugins.insert(dataset, function() {
      return typeof callback === "function" ? callback.apply(null, arguments) : void 0;
    });
  },
  findAll: function() {
    var callback, plugins;
    callback = arguments[arguments.length - 1];
    plugins = this.collection();
    return plugins.find().sort({
      _id: -1
    }).limit(1).toArray(function(err, doc) {
      var ref;
      if ((ref = doc[0]) != null ? ref._id : void 0) {
        delete doc[0]._id;
      }
      return typeof callback === "function" ? callback(err, doc) : void 0;
    });
  }
};

module.exports = function(options) {
  mongodb.db = mongojs(options);
  return mongodb;
};
