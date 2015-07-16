var connection, mongojs;

mongojs = require("mongojs");

connection = module.exports;

connection.getCollection = function(collection) {
  return this.db.collection(collection);
};

connection.createDbConnection = function(options) {
  if (!this.db) {
    this.db = mongojs(options);
  }
  return this.db;
};
