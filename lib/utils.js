(function() {
  var fs;

  fs = require('fs');

  exports.loadJsonFile = function(path, callback) {
    return fs.readFile(path, function(err, data) {
      if (err) {
        return callback(err);
      }
      try {
        return callback(null, JSON.parse(data.toString()));
      } catch (_error) {
        err = _error;
        return callback(err);
      }
    });
  };

}).call(this);
