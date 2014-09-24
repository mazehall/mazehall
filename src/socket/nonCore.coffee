socket = require "socket.io-client"
mazehall = require "mazehall"

modules = require "../modules"

components = mazehall.components
params = {query: {components: components}}

manager =
  socket: null
  method: []
  finish: ->
    delete @socket
  start: ->
    @socket = socket "http://#{mazehall.coreSocket}/socket", params unless @socket

    console.log "[socket:#{components}] core server > #{@socket.io.uri}"

    for name of @method
      manager.socket.on name, @method[name]

manager.method.connect = (socket) ->
  console.log "[socket:#{components}] connected to core!"
  @emit "mazehallCoreConfigGetInstalledModules"

manager.method.disconnect = (message) ->
  console.log "[socket:#{components}] %s: disconnected from core ...reconnect", message

manager.method.reconnect = (socket) ->
  console.log "[socket:#{components}] reconnection was successful"

manager.method.reconnect_error = (error) ->
  console.log "[socket:#{components}] failed to reconnect to core | %d: %s", error.description, error.message

manager.method.error = (error) ->
  console.log "[socket:#{components}] connection error | %d: %s", error.description, error.message

manager.method.mazehallCoreConfigInstalledModules = (data) ->
  return unless Array.isArray data
  console.log "[socket:#{components}] received modules (%d) ", data.length
  console.log "[socket:#{components}] [%s] %s @%s", (index+1), module.name, module.version for module, index in data if data?

  modules.synchronize data

module.exports = manager
