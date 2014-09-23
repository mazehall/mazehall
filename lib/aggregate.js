(function() {
  var aggregate, aggregated, fs, path, sortAggregateAssetsByWeight, sortByWeight, uglify, _;

  path = require('path');

  fs = require('fs');

  _ = require("lodash");

  uglify = require('uglify-js');

  aggregated = {
    header: {
      js: {
        data: null,
        weights: []
      },
      css: {
        data: null,
        weights: []
      }
    },
    footer: {
      js: {
        data: null,
        weights: []
      },
      css: {
        data: null,
        weights: []
      }
    }
  };

  aggregate = function(name, ext, asset, options) {
    var addInlineCode, group, libs, pushAggregatedData, readFile, readFiles, ugly, weight;
    readFiles = function(ext, filepath) {
      fs.readdir(filepath, function(err, files) {
        if (err) {
          return;
        }
        files.forEach(function(file) {
          if (!libs && (file !== "assets" && file !== "tests")) {
            readFile(ext, path.join(filepath, file));
          }
        });
      });
    };
    pushAggregatedData = function(ext, filename, data) {
      var code, group, ugly;
      if (ext === "js") {
        group = options.group || "footer";
        code = (options.global ? data.toString() + "\n" : "(function(){" + data.toString() + "})();");
        ugly = uglify.minify(code, {
          fromString: true,
          mangle: false
        });
        aggregated[group][ext].weights[filename] = {
          weight: weight,
          data: code
        };
      } else {
        group = options.group || "header";
        aggregated[group][ext].weights[filename] = {
          weight: weight,
          data: data.toString()
        };
      }
    };
    addInlineCode = function(ext, data) {
      var hash, md5;
      md5 = crypto.createHash("md5");
      md5.update(data);
      hash = md5.digest("hex");
      pushAggregatedData(ext, hash, data);
    };
    readFile = function(ext, filepath) {
      fs.readdir(filepath, function(err, files) {
        if (files) {
          return readFiles(ext, filepath);
        }
        if (path.extname(filepath) !== "." + ext) {
          return;
        }
        fs.readFile(filepath, function(fileErr, data) {
          var filename;
          if (!data) {
            readFiles(ext, filepath);
          } else {
            filename = filepath.split(process.cwd())[1];
            pushAggregatedData(ext, filename, data);
          }
        });
      });
    };
    options = options || {};
    ugly = null;
    group = options.group;
    weight = options.weight || 0;
    libs = true;
    if (asset) {
      return (options.inline ? addInlineCode(ext, asset) : readFile(ext, path.join(process.cwd(), asset)));
    }
    libs = false;
  };

  sortAggregateAssetsByWeight = function() {
    var ext, region, _results;
    _results = [];
    for (region in aggregated) {
      _results.push((function() {
        var _results1;
        _results1 = [];
        for (ext in aggregated[region]) {
          _results1.push(sortByWeight(region, ext));
        }
        return _results1;
      })());
    }
    return _results;
  };

  sortByWeight = function(group, ext) {
    var file, temp, weights;
    weights = aggregated[group][ext].weights;
    temp = [];
    for (file in weights) {
      temp.push({
        data: weights[file].data,
        weight: weights[file].weight
      });
    }
    return aggregated[group][ext].data = _.map(_.sortBy(temp, "weight"), function(value) {
      return value.data;
    }).join("\n");
  };

  exports.aggregateAsset = function(name, source, type, asset, options) {
    options = options || {};
    asset = (options.inline ? asset : (options.absolute ? asset : path.join(source, name, "public/assets", type, asset)));
    return aggregate(name, type, asset, options);
  };

  exports.aggregated = function(ext, group, callback) {
    if (aggregated[group][ext].data) {
      return callback(aggregated[group][ext].data);
    }
    sortAggregateAssetsByWeight();
    return callback(aggregated[group][ext].data);
  };

}).call(this);
