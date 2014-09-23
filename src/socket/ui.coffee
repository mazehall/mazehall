mazehall = require "mazehall"
params = {query: {mazehall_COMPONENT: mazehall.component}}
socket = require "socket.io-client"

manager =
  socket: null
  method: []
  finish: ->
    delete @socket
  start: ->
    @socket = socket "http://#{mazehall.coreSocket}/socket", params unless @socket

    console.log "[socket:ui] core server > #{@socket.io.uri}"

    for name of @method
      manager.socket.on name, @method[name]

    return@

manager.method.connect = (socket) ->
  console.log "[socket:ui] connected to core!"
  @emit "mazehallCoreConfigGetInstalledModules"

  return@

manager.method.disconnect = (message) ->
  console.log "[socket:ui] %s: disconnected from core ...reconnect", message

  return@

manager.method.reconnect = (socket) ->
  console.log "[socket:ui] reconnection was successful"

  return@

manager.method.reconnect_error = (error) ->
  console.log "[socket:ui] couldn’t reconnect to core | %d: %s", error.description, error.message

  return@

manager.method.error = (error) ->
  console.log "[socket:ui] connection error | %d: %s", error.description, error.message

  return@

manager.method.mazehallCoreConfigInstalledModules = (data) ->
  return unless Array.isArray data
  console.log "[socket:ui] received modules (%d) ", data.length
  console.log "[socket:ui] [%s] %s @%s", (index+1), module.name, module.version for module, index in data if data?

  modules = require "../modules"
  modules.synchronize data

  return@

module.exports = manager
