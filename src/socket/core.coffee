mazehall= require "mazehall"
socket  = require "socket.io"

modules = require "../modules"

manager =
  socket: null
  method: []
  finish: ->
    delete @socket
  start: (port) ->
    @listen = port || 3001
    @socket = socket.listen(@listen).of "/socket" unless @socket?
    @socket.on "connection", (socket) ->
      socket.mazehall =
        components: socket.handshake.query.components || 'null'

      return console.log "[socket:core] connection %s rejected - not a valid mazehall node", socket.handshake.address unless socket.mazehall.components

      console.log "[socket:core] %s is connected - components: %s", socket.handshake.address, socket.mazehall.components.toUpperCase()

      for name of manager.method
        socket.on name, manager.method[name]

    console.log "[socket:core] listening on port %d", @listen

manager.method.mazehallCoreConfigGetInstalledModules = ->
  console.log "[socket:core] push module list to connectors"

  socket = @
  components = (@mazehall.components).split ","

  modules.getModulesByComponents components, (err, packages) ->
    throw new Error err if err

    socket.emit "mazehallCoreConfigInstalledModules", packages

manager.method.disconnect = ->
  console.log "[socket:core] %s disconnect - components: %s", @handshake.address, @mazehall.components.toUpperCase()

manager.method.reconnect = (socket) ->
  console.log "[socket:core] reconnection was successful"

manager.method.error = (socket) ->
  console.log "[socket:core] connection error"

module.exports = manager