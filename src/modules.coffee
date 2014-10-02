path = require 'path'
fs = require 'fs'
shell = require 'shelljs'

aggregate = require "./aggregate"
utils = require "./utils"

modules =
  source: 'node_modules'
  packages: []
  callbacks: {}

  findModules: (callback) ->
    fullPath = path.join process.cwd(), modules.source

    counter = 0
    fs.readdir fullPath, (err, files) ->
      return callback if !files || !files.length ||  err?.code == 'ENOENT'
      return callback err if !files || !files.length || err

      files.forEach (file) ->
        return null if file[0] == "."
        counter += 1

        utils.loadJsonFile "#{fullPath}/#{file}/package.json", (err, data) ->
          counter -= 1
          return callback err, null if err

          if data and data?.mazehall?
            console.log "found mazehall module #{file}"
            modules.packages.push data

          return callback null, modules.packages if counter == 0

  getModulesByComponents: (components, callback) ->
    foundModules = []
    modulesFromComponents = []

    for component in components
      for index, pkg of modules.packages
        continue if not pkg?.components? or not Array.isArray pkg.components
        continue if (foundModules.indexOf pkg.name) >= 0
        continue if (pkg.components.indexOf component) is -1

        foundModules.push pkg.name
        modulesFromComponents.push pkg

    callback null, modulesFromComponents

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

    modules.getModulesByComponents components, (err, packages) ->
      return callback null, packages if packages.length <= 0

      counter = 0
      for index, pkg of packages
        counter++
        try
          modules.callbacks[pkg.name] = {"app": require pkg.name}
        catch e
          console.log "[error] enabling module #{pkg.name} failed with:", e.message

      for index of packages
        counter--
        callback null, modules.packages if !counter

  synchronize: (remotePackages, callback) ->
    return false if not remotePackages or not typeof remotePackages == "object"

    cleanUp = ->
      unless localModified
        console.log "[socket:#{components}] sync | none packages changed"
      else
        console.log "[socket:#{components}] sync | packages changed! ....restarting server"
        process.exit 1

    install = (pkg, callback) ->
      option = {}
      source = localModified = pkg.name
      option.repo = pkg.repository if pkg.repository

      console.log "[socket:#{components}] sync | install new package:", pkg.name

      modules.install source, option, ->
        callback null, true, pkg

    remove = (pkgName, callback) ->
      console.log "[socket:#{components}] sync | remove package:", pkgName

      modules.uninstall pkgName, (err) ->
        return callback err, null, pkgName if err
        callback err, true, pkgName

    local = []
    remote = []
    counter = 0
    localModified = false
    components = require('mazehall').components

    remote.push pkg.name for pkg, index in remotePackages
    local.push pkg.name for pkg, index in modules.packages

    console.log "[socket:#{components}] synchronize packages :"
    console.log "[socket:#{components}] sync | local packages: ", local
    console.log "[socket:#{components}] sync | remote packages: ", remote

    # eval packages for installation
    for pkg, index in remotePackages
      console.log "[socket:#{components}] sync | already installed package:", pkg.name if (local.indexOf pkg.name) >= 0
      continue if (local.indexOf pkg.name) >= 0

      counter += 1
      install pkg, (err, result, pkg) ->
        throw new Error err if err
        console.log "[socket:#{components}] sync | installation complete of package", pkg.name

        counter -= 1
        localModified = true
        cleanUp() if counter == 0

    # eval packages for removal
    for pkgName, index in local
      continue if (remote.indexOf pkgName) >= 0

      counter += 1
      remove pkgName, (err, result, pkgName) ->
        throw new Error err if err
        console.log "[socket:#{components}] sync | removing complete of package", pkgName

        counter -= 1
        localModified = true
        cleanUp() if counter == 0

  uninstall: (module, callback) ->
    return callback 'global npm not found' if not shell.which 'npm'

    shell.exec "npm remove " + module, (code, output) ->
      console.log "Error: npm uninstall failed" if code is not 0
      return callback output if code is not 0
      callback null, true

  install: (module, options, callback) ->
    return callback 'global npm not found' if not shell.which 'npm'

    source = options?.repo || module

    console.log "Installing module: %s from %s", module, options?.repo || "npm"
    shell.exec "npm install " + source, (code, output) ->
      console.log "Error: npm install failed" if code is not 0
      return callback output if code is not 0
      callback null, true

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