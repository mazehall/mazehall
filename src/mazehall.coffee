modules = require './modules'
aggregate = require "./aggregate"

mazehall =
  port: process.env.PORT || 3000
  components: (process.env.MAZEHALL_COMPONENTS ||  'core').split ","
  coreSocket: process.env.MAZEHALL_CORE_SOCKET || '127.0.0.1:3001'

mazehall.serve = (callback) ->
  return runCore callback if (mazehall.components.indexOf "core") >= 0
  runNonCore callback

runCore = (callback) ->
  require('./core') (err, app, db) ->
    throw err if err

    require('./socket/core').start()

    server = app.listen mazehall.port, () ->
      console.log "Mazehall core listening on port #{server.address().port}"
      callback err, app if callback

runNonCore = (callback) ->
  require('./nonCore') (err, app) ->
    throw err if err

    require('./socket/ui').start()

    server = app.listen mazehall.port, () ->
      console.log "Mazehall ui listening on port #{server.address().port}"
      callback err, app if callback

mazehall.isCore = ->
  return mazehall.components == "core"
mazehall.isUI = ->
  return mazehall.components == "ui"

module.exports = mazehall