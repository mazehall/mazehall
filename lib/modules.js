var _r, fs, modules, path;

path = require('path');

fs = require('fs');

_r = require('kefir');

modules = {
  packages: [],
  callbacks: {},
  dirEmitter: function(changedPath) {
    return function(emitter) {
      var fullPath, moduleSource;
      moduleSource = changedPath || 'app_modules';
      fullPath = path.join(process.cwd(), moduleSource);
      return fs.readdir(fullPath, function(err, files) {
        if (err) {
          emitter.error(err);
        } else {
          files.forEach(function(file) {
            return emitter.emit({
              module: file,
              path: path.join(fullPath, file)
            });
          });
        }
        return emitter.end();
      });
    };
  },
  readPackageJson: function(dirValue) {
    return _r.fromNodeCallback(function(cb) {
      return fs.readFile(path.join(dirValue.path, 'package.json'), function(err, data) {
        if (err) {
          cb(err);
        }
        try {
          dirValue.pkg = JSON.parse(data.toString());
          return cb(null, dirValue);
        } catch (_error) {
          err = _error;
          return cb(err);
        }
      });
    });
  }
};

module.exports = modules;
