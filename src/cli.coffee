program = require "commander"
shell = require "shelljs"
fs = require "fs"


###*
# Creates a new module skeleton
#
# @param  {string} path
# @param  {string} modulename
# @param  {string} [program]
###
exports.createAppModule = (path, modulename, program) ->
  path = if typeof path is "undefined" then "#{process.cwd()}/" else path

  ###* creates a 'app_modules' folder when not present *###
  if @isAppModulesExists() == false
    console.log "   \u001b[33m#{"warn"}\u001b[0m  : folder app_modules is not yet exists"
    @createDir "#{path}/app_modules"

  ###* stop when the target directory already exists and not forced *###
  if @hasAppModule(modulename) and program?.force != true
    console.log "   \u001b[31m#{"error"}\u001b[0m : module already #{modulename} exists"
    process.exit()

  template = @template.modules
  skeleton =
    ".gitignore": template.gitignore()
    ".bowerrc": template.bowerrc()
    "package.json": template.package_json()
    "index.js": template.index_js()
    "gulpfile.js": ""
    "bower.json": template.bower_json()
    "public": @createDir
    "public/src": @createDir
    "public/src/index.html": ""
    "public/src/css": @createDir
    "public/src/css/app.css": ""
    "public/src/js": @createDir
    "public/src/js/mazehallApp.js": "'use strict';"
    "public/src/js/controller": @createDir
    "public/src/templates": @createDir

  console.log "   \u001b[32m#{"create:"}\u001b[0m #{modulename} module"

  applyFiles = (path) ->
    for filename of skeleton
      if skeleton[filename] and typeof skeleton[filename] is "function"
        skeleton[filename].call null, path+filename
      exports.writeFile(path+filename, skeleton[filename]) if typeof skeleton[filename] is "string"
    return

  unless @hasAppModule(modulename)
    @createDir "#{path}app_modules/#{modulename}/", (path) -> applyFiles path
  else applyFiles("#{path}app_modules/#{modulename}/")

  ###* install package dependencies *###
  shell.exec "cd #{path} && npm install serve-static --save", (err) ->
    console.log err if err
    console.log "\n\u001b[32m#{"mazehall module #{modulename} was created!"}\u001b[0m"
    console.log "\n -> #{path}app_modules/#{modulename}\n"


###*
# Creates an new Mazehall app
#
# @param  {string} [path = process.cwd()]
# @param  {object} [program]
###
exports.createMazeApp = (path, program) ->
  path = if typeof path is "undefined" then "#{process.cwd()}/" else path

  ###* exit, when an application already exists and not forced *###
  if @isAppInstalled() and program?.force isnt true
    console.log "   \u001b[31m#{"error"}\u001b[0m : app.js or package.json already exists"
    process.exit()

  console.log "   \u001b[32m#{"create:"}\u001b[0m #{@getAppName()}"

  @createDir "#{path}/app_modules" if @isAppModulesExists() isnt false

  @writeFile "#{path}/app.js", @template.coreapp.app_js()
  @writeFile "#{path}/server.js", @template.coreapp.server_js()
  @writeFile "#{path}/package.json", @template.coreapp.package_json(), ->
    ###* install package dependencies *###
    shell.exec "cd #{path} && npm install mazehall express --save", (err) ->
      console.log err if err
      console.log "\n\u001b[32m#{"mazehall application was created!"}\u001b[0m"
      console.log "\n -> #{path}\n"
  return


###*
# Writes data to a file asynchronously
#
# @param {string} path
# @param {string} buffer
# @param {function(string):void} [callback]
###
exports.writeFile = (path, buffer, callback) ->
  try
    fs.writeFile path, buffer, ->
      console.log "   \u001b[32m#{"write"}\u001b[0m : #{path}"
      callback and callback.call(null, path)
  catch e
    throw e if e.code isnt "EEXIST"


###*
# Creates a non recursive directory
#
# @param {string} path
# @param {function(string):void} [callback]
###
exports.createDir = (path, callback) ->
  try
    fs.mkdirSync path
    console.log "   \u001b[36m#{"mkdir"}\u001b[0m : #{path}"
    callback and callback(path)
  catch e
    throw e if e.code isnt "EEXIST"


###*
# Returns the name of Directory
#
# @param  {string} [path = process.cwd()]
# @return {string}
###
exports.getDirectoryName = (path) ->
  filename = if typeof path is "undefined" then process.cwd() else path
  resolved = filename.split(if process.platform is "win32" then "\\" else "/")
  resolved[resolved.length - 1]


###*
# Return the name of the new Mazehall app
#
# @return {string}
###
exports.getAppName = ->
  ###* name from program argument or current directory name *###
  if not program.args? or program.args.length is 0 then @getDirectoryName() else program.args[0]


###*
# Checks if an app already exists
#
# @param  {string} [path = process.cwd()]
# @return {boolean}
###
exports.isAppInstalled = (path) ->
  path = if typeof path is "undefined" then process.cwd() else path
  fs.existsSync "#{path}/app.js" and "#{path}/package.json"


###*
# Checks if app_modules exists
#
# @param  {string} [path = process.cwd()]
# @return {boolean}
###
exports.isAppModulesExists = (path) ->
  path = if typeof path is "undefined" then process.cwd() else path
  fs.existsSync "#{path}app_modules" and "#{path}/app_modules"


###*
# Checks if the named module already exists
#
# @param  {string} modulename
# @return {boolean}
###
exports.hasAppModule = (modulename) ->
  fs.existsSync("#{process.cwd()}/app_modules/#{modulename}")


###*
#
# Template Generators
#
# @type {{coreapp: {package_json: Function, app_js: Function}, modules: {bowerrc: Function, gitignore: Function, bower_json: Function, index_js: Function, package_json: Function}}}
###
exports.template =

  ###*
  # @type object
  ###
  coreapp:

    ###*
    # Template : package.json
    #
    # @return {string}
    ###
    package_json: ->
      template =
        "name": exports.getAppName()
        "version": "0.1.0"
        "license": "MIT"
        "private": true
        "main": "server.js"
        "description": "mazehall application"
        "author": 'Mazehall Generator'
        "contributors": [
          {"name": "#"}
        ]
        "repository": "#"
      JSON.stringify template, null, 2

    ###*
    # Template : app.js
    #
    # @return {string}
    ###
    app_js: ->
      content = 'var mazehall = require(\'mazehall\');\n' +
      'var express = require(\'express\');\n' + '\n' +
      'var app, server;\n' +
      'app = express();\n' +
      'server = require(\'http\').Server(app);\n' +
      'mazehall.moduleStream.log(\'module loader\');\n' +
      'mazehall.initExpress(app);\n' +
      'module.exports = server;'
      content

    ###*
    # Template : server.js
    #
    # @return {string}
    ###
    server_js: ->
      content = 'var server = require(\'./app.js\');\n' +
      '\n' +
      'var port;\n' +
      'port = process.env.PORT || 3000\n' +
      'server.listen(port, function() {\n' +
      '  console.log(\'server listen on port: \' + port);\n' +
      '});'
      content

  ###*
  # @type object
  ###
  modules:

    ###*
    # Template : .bowerrc
    #
    # @return {string}
    ###
    bowerrc: ->
      template = "directory": "public/src/bower_components"
      JSON.stringify template, null, 2

    ###*
    # Template : .gitignore
    #
    # @return {string}
    ###
    gitignore: ->
      "\n.zedstate" + "\nnode_modules" + "\n.idea" + "\npublic/dist" + "\npublic/src/bower_components"

    ###*
    # Template : bower.json
    #
    # @return {string}
    ###
    bower_json: ->
      template =
        "name": exports.getAppName()
        "version": "0.1.0"
        "private": true
        "authors": ["Mazehall Generator"]
        "description": "example for the mazehall framework"
        "license": "MIT"
      JSON.stringify template, null, 2

    ###*
    # Template : index.js
    #
    # @return {string}
    ###
    index_js: ->
      template = ->
        path = require("path")
        serveStatic = require("serve-static")
        module.exports = useRouting: (app) ->
          env = process.env.NODE_ENV or "development"
          app.use serveStatic(path.join(__dirname, if env is "development" then "public/src" else "public/dist"))
          return
        return

      "(#{template.toString()}).call(this);"

    ###*
    # Template : package.json
    #
    # @return {string}
    ###
    package_json: ->
      template =
        "name": exports.getAppName()
        "version": "0.1.0"
        "private": true
        "description": "module"
        "main": "index.js"
        "mazehall": true
        "components": ["ui"]
        "author": "Mazehall Generator"
        "contributors": [
          {"name": "#"}
        ]
      JSON.stringify template, null, 2