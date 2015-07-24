connection = require "./connection"
mazecli = require "./../../../cli"
_r = require "kefir"

plugin =
  getCollection: -> connection.getCollection "plugins"

  tailCursor: ->
    plugins = @getCollection()
    plugins.find {}, {}, {tailable: true, timeout: false}

  save: (dataset) ->
    callback = arguments[arguments.length-1]
    plugins  = @getCollection()
    plugins.insert dataset, ->
      callback? arguments...

  findAll: ->
    callback = arguments[arguments.length-1]
    plugins  = @getCollection()
    plugins.find().sort(_id: -1).limit(1).toArray (err, doc) ->
      delete doc[0]._id if doc[0]?._id
      callback? err, doc

  initSync: ->
    stream = _r.fromEvents @tailCursor(), "data"
    stream.onValue -> mazecli.pluginSync()

module.exports = (options) ->
  connection.createDbConnection options
  plugin