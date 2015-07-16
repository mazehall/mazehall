mongojs = require "mongojs"

connection = module.exports
connection.getCollection = (collection) ->
  @db.collection collection

connection.createDbConnection = (options) ->
  @db = mongojs options unless @db
  @db