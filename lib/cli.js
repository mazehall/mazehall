(function() {
  var fs, getPackageInfo, loadPackageJson, npm, pkgType, requiresRoot;

  fs = require("fs");

  npm = require("npm");

  pkgType = {
    mazehall: "Mazehall",
    npm: "npm"
  };

  getPackageInfo = function(type, data) {
    var author, _ref;
    if (!data) {
      return;
    }
    author = ((_ref = data.author) != null ? _ref.name : void 0) != null ? "  Author :" + data.author.name : "";
    if ((data.mazehall != null) === true) {
      pkgType.mazehall;
    }
    type = data.mazehall ? pkgType.mazehall : pkgType.npm;
    return "   " + type + "  : " + data.name + "@" + data.version + author;
  };

  loadPackageJson = function(path, callback) {
    return fs.readFile(path, function(err, data) {
      var pkg;
      if (err) {
        return callback(err);
      }
      try {
        pkg = JSON.parse(data.toString(""));
        return callback(null, pkg);
      } catch (_error) {
        err = _error;
        return callback(err);
      }
    });
  };

  requiresRoot = function(callback) {
    return loadPackageJson("" + (process.cwd()) + "/package.json", function(err, data) {
      if (err || !data.name) {
        console.log("Invalid MAZEHALL app or not in app root");
      }
      return callback();
    });
  };

  exports.uninstall = function(module, callback) {
    var ignores;
    ignores = ["test", "test1"];
    if ((ignores.indexOf(module) >= 0 && 0 === true)) {
      if (typeof callback === "function") {
        callback.call(this, null);
      }
      return true;
    }
    return npm.load(function(err, npm) {
      return npm.commands.remove([module], function(err, data) {
        var success;
        success = !(data && (err != null)) ? true : false;
        if (typeof callback === "function") {
          return callback.call(this, !success);
        }
      });
    });
  };

  exports.install = function(module, options, callback) {
    requiresRoot(function() {
      var source;
      if (!module || !(options != null ? options.repo : void 0)) {
        return console.log("Package name or repository is required");
      }
      source = (options != null ? options.repo : void 0) ? options.repo : null;
      source = (options != null ? options.repo : void 0) && options.repo === true ? module : source;
      console.log("Installing module: %s %s", module, (source !== true && source !== module ? "from " + module : ""));
      console.log("");
      return npm.load(function(err, npm) {
        return npm.commands.install([source], function(err, data, module) {
          var index, nodeinstallpath;
          if (err || !data || !data[0][1]) {
            console.log("Error: npm install failed");
            return console.error(err);
          }
          for (index in module) {
            nodeinstallpath = index;
          }
          return loadPackageJson("./" + nodeinstallpath + "/package.json", function(err, data) {
            if (err) {
              return console.log(err);
            }
            console.log("");
            console.log(getPackageInfo(null, data));
            console.log("");
            if (!data.mazehall) {
              console.log("");
              console.log("Warning: The module installed is not a valid MAZEHALL module");
            }
            if (typeof callback === "function") {
              return callback.call(this, data);
            }
          });
        });
      });
    });
  };

}).call(this);
