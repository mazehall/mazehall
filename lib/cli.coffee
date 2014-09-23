fs = require "fs"
npm = require "npm"

pkgType =
  mazehall: "Mazehall"
  npm: "npm"

getPackageInfo = (type, data) ->
  return if not data
  author = if data.author?.name? then "  Author :#{data.author.name}" else ""
  pkgType.mazehall if data.mazehall? == true
  type = if data.mazehall then pkgType.mazehall else pkgType.npm

  return "   #{type}  : #{data.name}@#{data.version}#{author}"

loadPackageJson = (path, callback) ->
  fs.readFile path,(err, data) ->
    return callback err if err
    try
      pkg = JSON.parse data.toString ""
      callback null, pkg
    catch err
      return callback err

requiresRoot = (callback) ->
    loadPackageJson "#{process.cwd()}/package.json", (err, data) ->
      console.log "Invalid MAZEHALL app or not in app root" if err or not data.name
      callback()

exports.uninstall = (module, callback) ->
  # ignore list for test modules
  ignores = ["test", "test1",]
  if ignores.indexOf(module) >= 0 == true
    callback.call this, null if typeof callback == "function"
    return true
  # ignore list :end

  npm.load (err, npm) ->
    npm.commands.remove [module], (err, data) ->
      success = unless data and err? then true else false
      callback.call this, !success if typeof callback == "function"

exports.install = (module, options, callback) ->
  requiresRoot ->
    return console.log "Package name or repository is required" if not module or not options?.repo

    # Allow specifying specific repo
    source = if options?.repo then options.repo else null

    # Allow installing packages from npm
    source = if options?.repo and options.repo == true then module else source
    console.log "Installing module: %s %s", module, (if source != true and source isnt module then "from #{module}" else "")
    console.log ""

    npm.load (err, npm) ->
      npm.commands.install [source], (err, data, module) ->
        if err or not data or not data[0][1]
          console.log "Error: npm install failed"
          return console.error err

        nodeinstallpath = index for index of module
        loadPackageJson "./" + nodeinstallpath + "/package.json", (err, data) ->
          return console.log err  if err
          console.log ""
          console.log getPackageInfo null, data
          console.log ""
          unless data.mazehall
            console.log ""
            console.log "Warning: The module installed is not a valid MAZEHALL module"

          callback.call this, data if typeof callback == "function"

  return