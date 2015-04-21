mongojs = require "mongojs"
mongodb =
  collection: -> @db.collection "plugins"

  tailCursor: ->
    plugins = @collection()
    plugins.find {}, {}, {tailable: true, timeout: false}

  save: (dataset) ->
    callback = arguments[arguments.length-1]
    plugins  = @collection()
    plugins.insert dataset, ->
      callback? arguments...

  findAll: ->
    callback = arguments[arguments.length-1]
    plugins  = @collection()
    plugins.find().sort(_id: -1).limit(1).toArray (err, doc) ->
      delete doc[0]._id if doc[0]?._id
      callback? err, doc

module.exports = (options) ->
  mongodb.db = mongojs options
  mongodb