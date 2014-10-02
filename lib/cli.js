(function() {
  var fs, path;

  fs = require('fs');

  path = require('path');

  exports.init = function(name, source) {
    var modulePath, sourcePath;
    sourcePath = path.join(process.cwd(), source);
    modulePath = path.join(sourcePath, name);
    if (!fs.existsSync(source)) {
      return console.log('Source Folder %s does not exist', sourcePath);
    }
    if (fs.existsSync(modulePath)) {
      return console.log('There already is a Package %s in ', name, sourcePath);
    }
    return console.log('@todo implementation');
  };

}).call(this);
