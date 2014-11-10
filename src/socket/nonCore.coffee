jwt = require "jsonwebtoken"
io = require "socket.io-client"

modules = require "../modules"
secrets = require '../secrets'

events = []
components = ''
tokenData = {components: components}

manager = (coreSocket, initComponents) ->
  components = initComponents
  return console.log "[socket:#{components}] skipped socket init"  unless secrets?.mazehall?.socket?
  console.log "[socket:#{components}] init socket"

  socket = io "#{coreSocket}"

  console.log "[socket:#{components}] core server > #{socket.io.uri}"

  for name of events
    socket.on name, events[name]

events.connect = (socket) ->
  console.log "[socket:#{components}] connected to core!"

  token = jwt.sign tokenData, secrets.mazehall.socket, {expiresInMinutes: 60}

  console.log "[socket:#{components}] authentication with core..."
  @emit "authenticate", {"token", token}

events.authenticated = () ->
  console.log "[socket:#{components}] authenticated on core"
  @emit "mazehallCoreConfigGetInstalledModules"

events.disconnect = (message) ->
  console.log "[socket:#{components}] %s: disconnected from core ...reconnect", message

events.reconnect = (socket) ->
  console.log "[socket:#{components}] reconnection was successful"

events.reconnect_error = (error) ->
  console.log "[socket:#{components}] failed to reconnect to core | %d: %s", error.description, error.message

events.error = (error) ->
  console.log "[socket:#{components}] connection error | %d: %s", error.description, error.message

events.mazehallCoreConfigInstalledModules = (data) ->
  return unless Array.isArray data
  console.log "[socket:#{components}] received modules (%d) ", data.length
  console.log "[socket:#{components}] [%s] %s @%s", (index+1), module.name, module.version for module, index in data if data?

  modules.synchronize data

module.exports = manager
