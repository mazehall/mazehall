path = require 'path'

utils = require './utils'

Secrets = () ->
  environment = process.env.MAZEHALL_ENVIRONMENT || 'production'
  path = path.join process.cwd(), 'secrets', environment + '.json'

  try
    return require path
  catch
    return {}

module.exports = new Secrets()