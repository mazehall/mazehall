path = require('path')
fs = require 'fs'

aggregate = require "./aggregate"
utils = require "./utils"
cli = require "./cli"

modules =
  source: 'node_modules'
  packages: []
  callbacks: {}

  findModules: (callback) ->
    path = path.join process.cwd(), modules.source

    counter = 0
    fs.readdir path, (err, files) ->
      return callback if !files || !files.length ||  err?.code == 'ENOENT'
      return callback err if !files || !files.length || err

      files.forEach (file) ->
        return null if file[0] == "."
        counter += 1

        utils.loadJsonFile "#{path}/#{file}/package.json", (err, data) ->
          counter -= 1
          return callback err, null if err

          if data and data?.mazehall?
            console.log "found mazehall module #{file}"
            modules.packages.push data

          return callback null, modules.packages if counter == 0

  enableModules: (callback) ->
    console.log 'enable modules'

    return callback null, modules.packages if modules.packages.length <= 0

    counter = 0
    for index, pkg of modules.packages
      counter++
      try
        modules.callbacks[pkg.name] = {"app": require pkg.name}
      catch e
        console.log "[error] enabling module #{pkg.name} failed with:", e.message

    for index of modules.packages
      counter--
      callback(null, modules.packages) if !counter

  enableModulesByComponents: (components, callback) ->
    console.log 'enable modules by components'

    enabledModules = []
    modulesFromComponents = []

    for component in components
      console.log 'lookup modules for component:', component

      for index, pkg of modules.packages
        continue if not pkg?.components? or not Array.isArray pkg.components
        continue if (enabledModules.indexOf pkg.name) >= 0
        continue if (pkg.components.indexOf component) is -1

        enabledModules.push pkg.name
        modulesFromComponents.push pkg

    return callback null, modulesFromComponents if modulesFromComponents.length <= 0 || modules.packages.length <= 0

    counter = 0
    for index, pkg of modulesFromComponents
      counter++
      try
        modules.callbacks[pkg.name] = {"app": require pkg.name}
      catch e
        console.log "[error] enabling module #{pkg.name} failed with:", e.message

    for index of modulesFromComponents
      counter--
      callback null, modules.packages if !counter

  synchronize: (remotePackages, callback) ->
    return false if not remotePackages or not typeof remotePackages == "object"

    cleanUp = ->
      unless localModified
        console.log "[socket:ui] sync | none packages changed"
      else
        console.log "[socket:ui] sync | packages changed! ....restarting server"
        process.exit 1

    install = (pkg, callback) ->
      option = {}
      source = localModified = pkg.name
      option.repo = pkg.repository if pkg.repository

      console.log "[socket:ui] sync | install new package:", pkg.name

      cli.install source, option, ->
        callback null, true, pkg

    remove = (pkgName, callback) ->
      console.log "[socket:ui] sync | remove package:", pkgName

      cli.uninstall pkgName, (err) ->
        return callback err, null, pkgName if err
        callback err, true, pkgName

    local = []
    remote = []
    counter = 0
    localModified = false

    remote.push pkg.name for pkg, index in remotePackages
    local.push pkg.name for pkg, index in modules.packages

    console.log "[socket:ui] synchronize packages :"
    console.log "[socket:ui] sync | local packages: ", local
    console.log "[socket:ui] sync | remote packages: ", remote

    # eval packages for installation
    for pkg, index in remotePackages
      console.log "[socket:ui] sync | already installed package:", pkg.name if (local.indexOf pkg.name) >= 0
      continue if (local.indexOf pkg.name) >= 0

      counter += 1
      install pkg, (err, result, pkg) ->
        throw new Error err if err
        console.log "[socket:ui] sync | installation complete of package", pkg.name

        counter -= 1
        localModified = true
        cleanUp() if counter == 0

    # eval packages for removal
    for pkgName, index in local
      continue if (remote.indexOf pkgName) >= 0

      counter += 1
      remove pkgName, (err, result, pkgName) ->
        throw new Error err if err
        console.log "[socket:ui] sync | removing complete of package", pkgName

        counter -= 1
        localModified = true
        cleanUp() if counter == 0

  runPreRoutingCallbacks: (app) ->
    console.log 'call pre routing callbacks...'
    for name, data of modules.callbacks
      console.log "call pre routing callback of module #{name}"
      data.app.usePreRouting app if data.app?.usePreRouting? && typeof data.app.usePreRouting == "function"

  runRoutingCallbacks: (app) ->
    console.log 'call routing callbacks...'
    for name, data of modules.callbacks
      console.log "call routing callback of module #{name}"
      data.app.useRouting app if data.app?.useRouting? && typeof data.app.useRouting == "function"

  runPostRoutingCallbacks: (app) ->
    console.log 'call post routing callbacks...'
    for name, data of modules.callbacks
      console.log "call post routing callback of module #{name}"
      data.app.usePostRouting app if data.app?.usePostRouting? && typeof data.app.usePostRouting == "function"

  aggregateAsset: ->
    for name, data of modules.callbacks
      if data.app?.aggregateAssets?
        for asset in data.app.aggregateAssets
          aggregate.aggregateAsset.apply null, [name, modules.source, asset.type, asset.file, asset.options]

module.exports = modules