socket  = require 'socket.io'
express = require 'express'

modules = require './modules'
aggregate = require "./aggregate"

app = express()

mazehall =
  port: process.env.PORT || 3000
  components: (process.env.MAZEHALL_COMPONENTS ||  'core').split ","
  coreSocket: process.env.MAZEHALL_CORE_SOCKET || 'http://127.0.0.1:3000'
  app: app

  serve: (callback) ->
    if (mazehall.components.indexOf "core") >= 0
      runCore callback
    else
      runNonCore callback


runCore = (callback) ->
  bootstrap = require('./core')
  bootstrap app, (err) ->
    return callback err if err and callback
    throw err if err

    server = app.listen mazehall.port, () ->
      console.log "Mazehall core listening on port #{server.address().port}"
      mazehall.server = server

      require('./socket/core')(server)
      callback null, app if callback

runNonCore = (callback) ->
  bootstrap = require('./nonCore')
  bootstrap app, mazehall.components, (err) ->
    return callback err if err and callback
    throw err if err

    server = app.listen mazehall.port, () ->
      console.log "Mazehall #{mazehall.components} listening on port #{server.address().port}"
      mazehall.server = server

      require('./socket/nonCore')(mazehall.coreSocket, mazehall.components)
      callback null, app if callback

module.exports = mazehall