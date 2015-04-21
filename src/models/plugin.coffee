provider = require "./dataprovider"
modelsPlugin =
  provider: -> provider.getPlugin()
  getPlugins: (callback) ->
    @provider().findAll (err, plugins) ->
      callback? err, plugins...

  addPlugin: (plugin, callback) ->
    @getPlugins (err, plugins) ->
      return callback? if not plugin?.pkg?.name or err

      plugins[plugin.pkg.name] =
        version: plugin.pkg.version
        components: plugin.pkg.components ? []

      modelsPlugin.setPlugins plugins, callback

  deletePlugin: (name, callback) ->
    @getPlugins (err, plugins) ->
      return callback? true if err or plugins?[name] is undefined
      delete plugins[name] if plugins?[name]

      modelsPlugin.setPlugins plugins, callback

  setPlugins: ->
    @provider().save arguments...

  tailCursor: ->
    @provider().tailCursor arguments...

module.exports = modelsPlugin