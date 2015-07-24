dataprovider = module.exports
dataprovider.providers = {}
dataprovider.instances = {}

dataprovider.setProvider = (database, options = {}) ->
  throw new Error 'first argument must be an provider name' if not database
  @providers[database] =
    name : database
    opts : options
  @providers.use = database

dataprovider.getProvider = ->
  throw new Error 'database provider required - use setProvider' if not @providers.use
  @providers[@providers.use]

dataprovider.getPlugin = ->
  instance = "plugin"
  dataprovider.instances[instance] = loadModel instance unless dataprovider.instances[instance]
  dataprovider.instances[instance]

loadModel = (model) ->
  try
    provider = dataprovider.getProvider()
    instance = require("./#{provider.name}/#{model}") provider.opts
  catch error
    throw new Error "provider #{provider.name} does not have a #{model} model"
  instance