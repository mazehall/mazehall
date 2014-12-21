(function() {
  var bootstrap, modules;

  modules = require('./modules');

  bootstrap = function(app, components, callback) {
    console.log('bootstrap non core');
    return modules.findModules(function(err, foundModules) {
      if (err) {
        console.log('loading mazehall modules failed');
      }
      if (err) {
        return callback(err);
      }
      return modules.enableModulesByComponents(components, function(err, result) {
        if (err) {
          console.log('enabling mazehall modules failed');
        }
        if (err) {
          return callback(err);
        }
        modules.runPreRoutingCallbacks(app);
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
