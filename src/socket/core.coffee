socket  = require 'socket.io'
mazehall = require 'mazehall'

authorization = require('./authorization')
modules = require '../modules'
secrets = require '../secrets'

events =
  mazehallCoreConfigGetInstalledModules: () ->
    socket = @
    console.log "[socket:core] %s push modules by components list", @handshake.address
    modules.getModulesByComponents @decoded_token.components, (err, packages) ->
      throw new Error err if err
      socket.emit "mazehallCoreConfigInstalledModules", packages

  disconnect: () ->
    console.log "[socket:core] %s disconnect", @handshake.address

  reconnect: (socket) ->
    console.log "[socket:core] %s reconnection was successful", @handshake.address

  error: (socket) ->
    console.log "[socket:core] %s connection error", @handshake.address

manager = ->
  return console.log "[socket:core] skipped socket init"  unless secrets?.mazehall?.socket?
  console.log "[socket:core] init socket"

  io = socket(mazehall.server);
  io.on 'connection', authorization.authOnEvent
    secret: secrets.mazehall.socket
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


module.exports = manager