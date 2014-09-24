(function() {
  var aggregate, cli, fs, modules, path, utils;

  path = require('path');

  fs = require('fs');

  aggregate = require("./aggregate");

  utils = require("./utils");

  cli = require("./cli");

  modules = {
    source: 'node_modules',
    packages: [],
    callbacks: {},
    findModules: function(callback) {
      var counter;
      path = path.join(process.cwd(), modules.source);
      counter = 0;
      return fs.readdir(path, function(err, files) {
        if (!files || !files.length || (err != null ? err.code : void 0) === 'ENOENT') {
          return callback;
        }
        if (!files || !files.length || err) {
          return callback(err);
        }
        return files.forEach(function(file) {
          if (file[0] === ".") {
            return null;
          }
          counter += 1;
          return utils.loadJsonFile("" + path + "/" + file + "/package.json", function(err, data) {
            counter -= 1;
            if (err) {
              return callback(err, null);
            }
            if (data && ((data != null ? data.mazehall : void 0) != null)) {
              console.log("found mazehall module " + file);
              modules.packages.push(data);
            }
            if (counter === 0) {
              return callback(null, modules.packages);
            }
          });
        });
      });
    },
    enableModules: function(callback) {
      var counter, e, index, pkg, _ref, _results;
      console.log('enable modules');
      if (modules.packages.length <= 0) {
        return callback(null, modules.packages);
      }
      counter = 0;
      _ref = modules.packages;
      for (index in _ref) {
        pkg = _ref[index];
        counter++;
        try {
          modules.callbacks[pkg.name] = {
            "app": require(pkg.name)
          };
        } catch (_error) {
          e = _error;
          console.log("[error] enabling module " + pkg.name + " failed with:", e.message);
        }
      }
      _results = [];
      for (index in modules.packages) {
        counter--;
        if (!counter) {
          _results.push(callback(null, modules.packages));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    enableModulesByComponents: function(components, callback) {
      var component, counter, e, enabledModules, index, modulesFromComponents, pkg, _i, _len, _ref, _results;
      console.log('enable modules by components');
      enabledModules = [];
      modulesFromComponents = [];
      for (_i = 0, _len = components.length; _i < _len; _i++) {
        component = components[_i];
        console.log('lookup modules for component:', component);
        _ref = modules.packages;
        for (index in _ref) {
          pkg = _ref[index];
          if (((pkg != null ? pkg.components : void 0) == null) || !Array.isArray(pkg.components)) {
            continue;
          }
          if ((enabledModules.indexOf(pkg.name)) >= 0) {
            continue;
          }
          if ((pkg.components.indexOf(component)) === -1) {
            continue;
          }
          enabledModules.push(pkg.name);
          modulesFromComponents.push(pkg);
        }
      }
      if (modulesFromComponents.length <= 0 || modules.packages.length <= 0) {
        return callback(null, modulesFromComponents);
      }
      counter = 0;
      for (index in modulesFromComponents) {
        pkg = modulesFromComponents[index];
        counter++;
        try {
          modules.callbacks[pkg.name] = {
            "app": require(pkg.name)
          };
        } catch (_error) {
          e = _error;
          console.log("[error] enabling module " + pkg.name + " failed with:", e.message);
        }
      }
      _results = [];
      for (index in modulesFromComponents) {
        counter--;
        if (!counter) {
          _results.push(callback(null, modules.packages));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    synchronize: function(remotePackages, callback) {
      var cleanUp, counter, index, install, local, localModified, pkg, pkgName, remote, remove, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _results;
      if (!remotePackages || !typeof remotePackages === "object") {
        return false;
      }
      cleanUp = function() {
        if (!localModified) {
          return console.log("[socket:ui] sync | none packages changed");
        } else {
          console.log("[socket:ui] sync | packages changed! ....restarting server");
          return process.exit(1);
        }
      };
      install = function(pkg, callback) {
        var localModified, option, source;
        option = {};
        source = localModified = pkg.name;
        if (pkg.repository) {
          option.repo = pkg.repository;
        }
        console.log("[socket:ui] sync | install new package:", pkg.name);
        return cli.install(source, option, function() {
          return callback(null, true, pkg);
        });
      };
      remove = function(pkgName, callback) {
        console.log("[socket:ui] sync | remove package:", pkgName);
        return cli.uninstall(pkgName, function(err) {
          if (err) {
            return callback(err, null, pkgName);
          }
          return callback(err, true, pkgName);
        });
      };
      local = [];
      remote = [];
      counter = 0;
      localModified = false;
      for (index = _i = 0, _len = remotePackages.length; _i < _len; index = ++_i) {
        pkg = remotePackages[index];
        remote.push(pkg.name);
      }
      _ref = modules.packages;
      for (index = _j = 0, _len1 = _ref.length; _j < _len1; index = ++_j) {
        pkg = _ref[index];
        local.push(pkg.name);
      }
      console.log("[socket:ui] synchronize packages :");
      console.log("[socket:ui] sync | local packages: ", local);
      console.log("[socket:ui] sync | remote packages: ", remote);
      for (index = _k = 0, _len2 = remotePackages.length; _k < _len2; index = ++_k) {
        pkg = remotePackages[index];
        if ((local.indexOf(pkg.name)) >= 0) {
          console.log("[socket:ui] sync | already installed package:", pkg.name);
        }
        if ((local.indexOf(pkg.name)) >= 0) {
          continue;
        }
        counter += 1;
        install(pkg, function(err, result, pkg) {
          if (err) {
            throw new Error(err);
          }
          console.log("[socket:ui] sync | installation complete of package", pkg.name);
          counter -= 1;
          localModified = true;
          if (counter === 0) {
            return cleanUp();
          }
        });
      }
      _results = [];
      for (index = _l = 0, _len3 = local.length; _l < _len3; index = ++_l) {
        pkgName = local[index];
        if ((remote.indexOf(pkgName)) >= 0) {
          continue;
        }
        counter += 1;
        _results.push(remove(pkgName, function(err, result, pkgName) {
          if (err) {
            throw new Error(err);
          }
          console.log("[socket:ui] sync | removing complete of package", pkgName);
          counter -= 1;
          localModified = true;
          if (counter === 0) {
            return cleanUp();
          }
        }));
      }
      return _results;
    },
    runPreRoutingCallbacks: function(app) {
      var data, name, _ref, _ref1, _results;
      console.log('call pre routing callbacks...');
      _ref = modules.callbacks;
      _results = [];
      for (name in _ref) {
        data = _ref[name];
        console.log("call pre routing callback of module " + name);
        if ((((_ref1 = data.app) != null ? _ref1.usePreRouting : void 0) != null) && typeof data.app.usePreRouting === "function") {
          _results.push(data.app.usePreRouting(app));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    runRoutingCallbacks: function(app) {
      var data, name, _ref, _ref1, _results;
      console.log('call routing callbacks...');
      _ref = modules.callbacks;
      _results = [];
      for (name in _ref) {
        data = _ref[name];
        console.log("call routing callback of module " + name);
        if ((((_ref1 = data.app) != null ? _ref1.useRouting : void 0) != null) && typeof data.app.useRouting === "function") {
          _results.push(data.app.useRouting(app));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    runPostRoutingCallbacks: function(app) {
      var data, name, _ref, _ref1, _results;
      console.log('call post routing callbacks...');
      _ref = modules.callbacks;
      _results = [];
      for (name in _ref) {
        data = _ref[name];
        console.log("call post routing callback of module " + name);
        if ((((_ref1 = data.app) != null ? _ref1.usePostRouting : void 0) != null) && typeof data.app.usePostRouting === "function") {
          _results.push(data.app.usePostRouting(app));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    aggregateAsset: function() {
      var asset, data, name, _ref, _ref1, _results;
      _ref = modules.callbacks;
      _results = [];
      for (name in _ref) {
        data = _ref[name];
        if (((_ref1 = data.app) != null ? _ref1.aggregateAssets : void 0) != null) {
          _results.push((function() {
            var _i, _len, _ref2, _results1;
            _ref2 = data.app.aggregateAssets;
            _results1 = [];
            for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
              asset = _ref2[_i];
              _results1.push(aggregate.aggregateAsset.apply(null, [name, modules.source, asset.type, asset.file, asset.options]));
            }
            return _results1;
          })());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  };

  module.exports = modules;

}).call(this);
