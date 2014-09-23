fs = require 'fs'

exports.loadJsonFile = (path, callback) ->
  fs.readFile path,(err, data) ->
    return callback err if err
    try
      callback null, JSON.parse data.toString()
    catch err
      return callback err