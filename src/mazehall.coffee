modules = require './modules'
_r = require 'kefir'
modelplugin = require "./models/plugin"

mazehall = {}
mazehall.moduleStream = _r.bus()

mazehall.getComponentMask = ->
  components = (process.env.MAZEHALL_COMPONENTS ||  '').split ","
  if (components.indexOf "core") >= 0
    components = ['']
  return components


### events in time

  mazehallStream
  directory:   --d---d--|
  dirEmitter:    D---D--|     {module:'x',path:'<modulePath>'}
  .flatMap:      -Dp---Dp-|   {module:'x',path:'<modulePath>',pkg:{<package.json>}}
  .filter:       -Dp---Dp-|   mazehall:true
  .filter:       -Dp------|   componentMask
  return:         M-------|

  moduleStream ---m---------  {module:'x',components:['a','']}
###
mazehall.loadStream = (options={}) ->
  componentMask = mazehall.getComponentMask()
  directoryStream = _r.fromBinder modules.dirEmitter(options.appModuleSource if options.appModuleSource)
  packagesStream = directoryStream
  .flatMap modules.readPackageJson
  .filter (x) -> x.pkg.mazehall
  .filter isPackageEnabled componentMask

  mazehallStream = packagesStream
  .map (module) ->
    require module.path

  mazehall.moduleStream.plug packagesStream.map (e) -> {module: e.pkg.name, components: e.pkg.components}
  return mazehallStream

mazehall.loadPluginStream = (options={}) ->
  directoryStream = _r.fromBinder modules.dirEmitter(options.appModuleSource if options.appModuleSource)
  directoryStream.flatMap modules.readPackageJson
  .filter (x) -> x.pkg.mazehall

mazehall.setDatabase = (provider, options) ->
  dataprovider = require "./models/dataprovider"
  dataprovider.setProvider provider, options

mazehall.initPlugins = (app, sync=false, options={}) ->
  throw new Error 'first argument "app" required' if not app
  pluginSource = if options.pluginSource then options.pluginSource else "node_modules"
  pluginStream = mazehall.loadPluginStream {appModuleSource: pluginSource}
  pluginStream.onValue (module) ->
      require(module.path) app

  return if sync isnt true
  mazecli = require "./cli"
  stream = _r.fromEvent modelplugin.tailCursor(), "data"
  stream.onValue -> mazecli.pluginSync()

mazehall.initExpress = (app, options={}) ->
  if not app
    throw new Error 'first argument "app" required'
  mazehall.loadStream options
  .onValue (module) ->
    module.useRouting? app


isPackageEnabled = (mask) ->
  (item) ->
    item.pkg.components ?= []
    item.pkg.components.push ''
    true in (enabler in item.pkg.components for enabler in mask)

module.exports = mazehall