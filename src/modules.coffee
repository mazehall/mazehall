path = require 'path'
fs = require 'fs'
_r = require 'kefir'

modules =
  packages: []
  callbacks: {}

  dirEmitter: (changedPath) ->
    (emitter) ->
      moduleSource = changedPath || 'app_modules'
      fullPath = path.join process.cwd(), moduleSource
      fs.readdir fullPath, (err, files) ->
        if err
          emitter.error(err)
        else
          files.forEach (file) ->
            emitter.emit({
              module: file
              path: path.join fullPath, file
            })
        emitter.end()

  readPackageJson: (dirValue) ->
    _r.fromNodeCallback (cb) ->
      fs.readFile path.join(dirValue.path, 'package.json'), (err, data) ->
        cb err if err
        try
          dirValue.pkg = JSON.parse data.toString()
          cb null, dirValue
        catch err
          cb err


module.exports = modules