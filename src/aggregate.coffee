path = require 'path'
fs = require 'fs'

_ = require "lodash"
uglify = require 'uglify-js'


aggregated =
  header:
    js:
      data: null
      weights: []

    css:
      data: null
      weights: []

  footer:
    js:
      data: null
      weights: []

    css:
      data: null
      weights: []


aggregate = (name, ext, asset, options) ->

  #Allow libs

  #Deny Libs
  readFiles = (ext, filepath) ->
    fs.readdir filepath, (err, files) ->
      return  if err
      files.forEach (file) ->
        readFile ext, path.join(filepath, file)  if not libs and (file isnt "assets" and file isnt "tests")
        return
      return

    return
  pushAggregatedData = (ext, filename, data) ->
    if ext is "js"
      group = options.group or "footer"
      code = (if options.global then data.toString() + "\n" else "(function(){" + data.toString() + "})();")
      ugly = uglify.minify(code,
        fromString: true
        mangle: false
      )
      aggregated[group][ext].weights[filename] =
        weight: weight
        data: code
    else
      group = options.group or "header"
      aggregated[group][ext].weights[filename] =
        weight: weight
        data: data.toString()
    return
  addInlineCode = (ext, data) ->
    md5 = crypto.createHash("md5")
    md5.update data
    hash = md5.digest("hex")
    pushAggregatedData ext, hash, data
    return
  readFile = (ext, filepath) ->
    fs.readdir filepath, (err, files) ->
      return readFiles(ext, filepath)  if files
      return  if path.extname(filepath) isnt "." + ext
      fs.readFile filepath, (fileErr, data) ->
        unless data
          readFiles ext, filepath
        else
          filename = filepath.split(process.cwd())[1]
          pushAggregatedData ext, filename, data
        return

      return

    return
  options = options or {}
  ugly = null
  group = options.group
  weight = options.weight or 0

  libs = true
  return (if options.inline then addInlineCode(ext, asset) else readFile(ext, path.join(process.cwd(), asset)))  if asset
  libs = false
#  events.on "modulesFound", ->
#    for name of modules
#      readFiles ext, path.join(process.cwd(), modules[name].source, name.toLowerCase(), "public")
#    return

  return

sortAggregateAssetsByWeight = ->
  for region of aggregated
    for ext of aggregated[region]
      sortByWeight region, ext

sortByWeight = (group, ext) ->
  weights = aggregated[group][ext].weights
  temp = []
  for file of weights
    temp.push
      data: weights[file].data
      weight: weights[file].weight

  aggregated[group][ext].data = _.map(_.sortBy(temp, "weight"), (value) ->
    value.data
  ).join("\n")


exports.aggregateAsset = (name, source, type, asset, options) ->
  options = options or {}

  asset = (if options.inline then asset else ((if options.absolute then asset else path.join(source, name, "public/assets", type, asset))))
  aggregate name, type, asset, options

exports.aggregated = (ext, group, callback) ->
  # Aggregated Data already exists and is ready
  return callback(aggregated[group][ext].data)  if aggregated[group][ext].data
  # No aggregated data exists so we will build it
  sortAggregateAssetsByWeight()
  # Returning rebuild data. All from memory so no callback required
  callback aggregated[group][ext].data