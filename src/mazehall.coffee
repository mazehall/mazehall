modules = require './modules'
_r = require 'kefir'

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