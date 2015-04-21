provider = {}
database =
  setProvider: (database, options = {}) ->
    throw new Error 'first argument database "provider" required' if not database
    provider.name = database
    provider.opts = options

  getProvider: ->
    throw new Error 'database provider required - use setProvider' if not provider.name
    provider

  getPlugin: ->
    provider = @getProvider()
    require("./#{provider.name}/plugin") provider.opts

module.exports = database