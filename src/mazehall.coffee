modules = require './modules'
_r = require 'kefir'

mazehall = {}

mazehall.getComponentMask = ->
  components = (process.env.MAZEHALL_COMPONENTS ||  '').split ","
  if (components.indexOf "core") >= 0
    components = ['']
  return components

mazehall.init = (app, options={}) ->
  if not app
    throw new Error 'first argument "app" required'
  componentMask = mazehall.getComponentMask()

  directoryStream = _r.fromBinder modules.dirEmitter(options.appModuleSource if options.appModuleSource)
  packagesStream = directoryStream
    .flatMap modules.readPackageJson
    .filter (x) -> x.pkg.mazehall
  mazehallStream = packagesStream.filter isPackageEnabled componentMask
  mazehallStream.onValue (module) ->
    _m = require module.path
    _m.usePreRouting? app
    _m.useRouting? app
    _m.usePostRouting? app

  responseStream = _r.bus()
  responseStream.plug mazehallStream.map (e) -> {module: e.pkg.name, components: e.pkg.components}
  return responseStream

isPackageEnabled = (mask) ->
  (item) ->
    item.pkg.components ?= []
    item.pkg.components.push ''
    true in (enabler in item.pkg.components for enabler in mask)

module.exports = mazehall