mazehall= require "mazehall"
modules = require "../modules"
socket  = require "socket.io"

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
        component: socket.handshake.query.mazehall_COMPONENT || null

      return console.log "[socket:core] connection %s rejected - not a valid mazehall node", socket.handshake.address unless socket.mazehall.component

      console.log "[socket:core] %s are connected - component: %s", socket.handshake.address, socket.mazehall.component.toUpperCase()

      for name of manager.method
        socket.on name, manager.method[name]

      # join the socket to an component channel
      socket.join socket.mazehall.component.toLowerCase()

    console.log "[socket:core] listening on port %d", @listen

    return@

manager.method.mazehallCoreConfigInstallModule = (module) ->
  # component: admin check
  console.log "[socket:core] add new package: ", module.name

  option = {}
  source = module.name

  if module?.repository && module?.type == "npm"
    option.repo = source = module.repository

  cli = require "./../cli"
  cli.install source, option, ->
    console.log "[socket:ui] sync | broadcast install complete"

    # emitting to component channel
    # @todo get installed component type and emit it
    components = "ui"
    newmodules = []
    manager.socket.to(components).emit "mazehallCoreConfigInstalledModules", newmodules
    manager.socket.to(components).emit "mazehallCoreConfigAvailableModules", newmodules

  return@

manager.method["mazehallCoreConfigUninstallModule"] = (module) ->
  # component: admin check
  console.log "[socket:core] remove package: ", module;

  cli = require "./../cli"
  cli.uninstall module.name, ->
    console.log "[socket:ui] sync | broadcast remove complete"

    # emitting to component channel
    # @todo get uninstalled component
    components = "ui"
    newmodules = []
    manager.socket.to(components).emit "mazehallCoreConfigInstalledModules", newmodules
    manager.socket.to(components).emit "mazehallCoreConfigAvailableModules", newmodules

  return@


manager.method.mazehallCoreConfigGetAvailableModules = ->

  modules = [
    { name: 'example-npm-vpopqmail',version: '0.0.1', repository: '.dummy-repository/example-npm-vpopqmail/', type: 'npm'},
    { name: 'example-npm-nginx',version: '0.0.1', repository: '.dummy-repository/example-npm-nginx/', type: 'npm' }
  ]

  @emit "mazehallCoreConfigAvailableModules", modules

  return@

manager.method.mazehallCoreConfigGetInstalledModules = ->
  console.log "[socket:core] push module list to connectors"

  socket  = @
  socket.emit "mazehallCoreConfigInstalledModules", modules.packages

  return@

manager.method.disconnect = ->
  console.log "[socket:core] %s disconnect - component: %s", @handshake.address, @mazehall.component.toUpperCase()
  @leave @mazehall.component.toLowerCase()

  return@

manager.method.reconnect = (socket) ->
  console.log "[socket:core] reconnection was successful"

  return@

manager.method.error = (socket) ->
  console.log "[socket:core] connection error"

  return@

module.exports = manager