socket  = require "socket.io"

modules = require './modules'
aggregate = require "./aggregate"


mazehall =
  port: process.env.PORT || 3000
  components: (process.env.MAZEHALL_COMPONENTS ||  'core').split ","
  coreSocket: process.env.MAZEHALL_CORE_SOCKET || 'http://127.0.0.1:3000'

mazehall.serve = (callback) ->
  return runCore callback if (mazehall.components.indexOf "core") >= 0
  runNonCore callback

runCore = (callback) ->
  require('./core') (err, app, db) ->
    throw err if err

    mazehall.app = app

    server = app.listen mazehall.port, () ->
      console.log "Mazehall core listening on port #{server.address().port}"
      mazehall.server = server

      require('./socket/core')()
      callback err, app if callback

runNonCore = (callback) ->
  require('./nonCore') (err, app) ->
    throw err if err

    mazehall.app = app

    server = app.listen mazehall.port, () ->
      console.log "Mazehall #{mazehall.components} listening on port #{server.address().port}"
      mazehall.server = server

      require('./socket/nonCore')()
      callback err, app if callback

module.exports = mazehall