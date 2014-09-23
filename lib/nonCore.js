(function() {
  var aggregate, bootstrap, express, mazehall, modules;

  express = require('express');

  mazehall = require('mazehall');

  modules = require('./modules');

  aggregate = require("./aggregate");

  bootstrap = function(callback) {
    console.log('bootstrap non core');
    return modules.findModules(function(err, foundModules) {
      if (err) {
        console.log('loading mazehall modules failed');
      }
      if (err) {
        return callback(err);
      }
      return modules.enableModulesByComponents(mazehall.components, function(err, result) {
        var app;
        if (err) {
          console.log('enabling mazehall modules failed');
        }
        if (err) {
          return callback(err);
        }
        app = express();
        modules.aggregateAsset();
        modules.runPreRoutingCallbacks(app);
        app.get("/modules/aggregated.js", function(req, res) {
          res.setHeader("content-type", "text/javascript");
          return aggregate.aggregated("js", (req.query.group ? req.query.group : "footer"), function(data) {
            return res.send(data);
          });
        });
        app.get("/modules/aggregated.css", function(req, res) {
          res.setHeader("content-type", "text/css");
          return aggregate.aggregated("css", (req.query.group ? req.query.group : "header"), function(data) {
            return res.send(data);
          });
        });
        modules.runRoutingCallbacks(app);
        modules.runPostRoutingCallbacks(app);
        app.use(function(req, res, next) {
          var method;
          method = req.method.toLowerCase();
          if (method === 'get') {
            res.status(404);
          } else {
            res.status(405);
          }
          return res.send();
        });
        app.use(function(err, req, res, next) {
          res.status(err.status || 500);
          return res.send(err.message);
        });
        return callback(err, app);
      });
    });
  };

  module.exports = bootstrap;

}).call(this);
