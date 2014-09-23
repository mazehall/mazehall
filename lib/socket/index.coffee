mazehall = require('mazehall');

module.exports = require("./core") if mazehall.isCore()
module.exports = require("./ui")   if mazehall.isUI()
