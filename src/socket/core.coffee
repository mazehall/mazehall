socket  = require 'socket.io'
mazehall = require 'mazehall'

authorization = require('./authorization')
modules = require '../modules'

events = []
manager = () ->
  io = socket(mazehall.server);

  io.on 'connection', authorization.authOnEvent
    secret: 'your secret or public key'
    timeout: 15000
  , (err, socket) ->
    return socket.disconnect err if err

    # assert components compatibility
    return socket.disconnect 'no components supplied' unless socket.decoded_token.components
    return socket.disconnect 'no components supplied' unless Object.prototype.toString.call socket.decoded_token.components  isnt '[object Array]'

    # publish events for this socket
    for name of events
      socket.on name, events[name]

    # emit non core that it is authenticated and ready to go
    socket.emit "authenticated"

events.mazehallCoreConfigGetInstalledModules = ->
  socket = @

  console.log "[socket:core] %s push modules by components list", @handshake.address

  modules.getModulesByComponents @decoded_token.components, (err, packages) ->
    throw new Error err if err

    socket.emit "mazehallCoreConfigInstalledModules", packages

events.disconnect = ->
  console.log "[socket:core] %s disconnect", @handshake.address

events.reconnect = (socket) ->
  console.log "[socket:core] %s reconnection was successful", @handshake.address

events.error = (socket) ->
  console.log "[socket:core] %s connection error", @handshake.address

module.exports = manager