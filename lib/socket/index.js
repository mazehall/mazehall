(function() {
  var mazehall;

  mazehall = require('mazehall');

  if (mazehall.isCore()) {
    module.exports = require("./core");
  }

  if (mazehall.isUI()) {
    module.exports = require("./ui");
  }

}).call(this);
