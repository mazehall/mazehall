var database, provider;

provider = {};

database = {
  setProvider: function(database, options) {
    if (options == null) {
      options = {};
    }
    if (!database) {
      throw new Error('first argument database "provider" required');
    }
    provider.name = database;
    return provider.opts = options;
  },
  getProvider: function() {
    if (!provider.name) {
      throw new Error('database provider required - use setProvider');
    }
    return provider;
  },
  getPlugin: function() {
    provider = this.getProvider();
    return require("./" + provider.name + "/plugin")(provider.opts);
  }
};

module.exports = database;
