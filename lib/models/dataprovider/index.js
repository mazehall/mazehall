var dataprovider, loadModel;

dataprovider = module.exports;

dataprovider.providers = {};

dataprovider.instances = {};

dataprovider.setProvider = function(database, options) {
  if (options == null) {
    options = {};
  }
  if (!database) {
    throw new Error('first argument must be an provider name');
  }
  this.providers[database] = {
    name: database,
    opts: options
  };
  return this.providers.use = database;
};

dataprovider.getProvider = function() {
  if (!this.providers.use) {
    throw new Error('database provider required - use setProvider');
  }
  return this.providers[this.providers.use];
};

dataprovider.getPlugin = function() {
  var instance;
  instance = "plugin";
  if (!dataprovider.instances[instance]) {
    dataprovider.instances[instance] = loadModel(instance);
  }
  return dataprovider.instances[instance];
};

loadModel = function(model) {
  var error, instance, provider;
  try {
    provider = dataprovider.getProvider();
    instance = require("./" + provider.name + "/" + model)(provider.opts);
  } catch (_error) {
    error = _error;
    throw new Error("provider " + provider.name + " does not have a " + model + " model");
  }
  return instance;
};
