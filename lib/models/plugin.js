var modelsPlugin, provider,
  slice = [].slice;

provider = require("./dataprovider");

modelsPlugin = {
  provider: function() {
    return provider.getPlugin();
  },
  getPlugins: function(callback) {
    return this.provider().findAll(function(err, plugins) {
      return typeof callback === "function" ? callback.apply(null, [err].concat(slice.call(plugins))) : void 0;
    });
  },
  addPlugin: function(plugin, callback) {
    return this.getPlugins(function(err, plugins) {
      var ref, ref1;
      if (!(plugin != null ? (ref = plugin.pkg) != null ? ref.name : void 0 : void 0) || err) {
        return callback != null;
      }
      plugins[plugin.pkg.name] = {
        version: plugin.pkg.version,
        components: (ref1 = plugin.pkg.components) != null ? ref1 : []
      };
      return modelsPlugin.setPlugins(plugins, callback);
    });
  },
  deletePlugin: function(name, callback) {
    return this.getPlugins(function(err, plugins) {
      if (err || (plugins != null ? plugins[name] : void 0) === void 0) {
        return typeof callback === "function" ? callback(true) : void 0;
      }
      if (plugins != null ? plugins[name] : void 0) {
        delete plugins[name];
      }
      return modelsPlugin.setPlugins(plugins, callback);
    });
  },
  setPlugins: function() {
    var ref;
    return (ref = this.provider()).save.apply(ref, arguments);
  },
  tailCursor: function() {
    var ref;
    return (ref = this.provider()).tailCursor.apply(ref, arguments);
  }
};

module.exports = modelsPlugin;
