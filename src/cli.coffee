fs = require 'fs'
path = require 'path'

exports.init = (name, source) ->
  sourcePath = path.join(process.cwd(), source);
  modulePath = path.join(sourcePath, name);

  return console.log 'Source Folder %s does not exist', sourcePath if not fs.existsSync(source)
  return console.log 'There already is a Package %s in ', name, sourcePath if fs.existsSync(modulePath)

  console.log '@todo implementation'