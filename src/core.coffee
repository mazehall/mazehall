modules = require './modules'

bootstrap = (app, callback) ->
  console.log 'bootstrap core'

  modules.findModules (err, foundModules) ->
    console.log 'loading mazehall modules failed' if err
    return callback err if err

    modules.enableModules (err, result) ->
      console.log 'enabling mazehall modules failed' if err
      return callback err if err

      #run routing callbacks
      modules.runPreRoutingCallbacks app

      #run routing callbacks
      modules.runRoutingCallbacks app

      #run post routing callbacks
      modules.runPostRoutingCallbacks app

      app.use (req, res, next) ->
        method = req.method.toLowerCase()
        if (method is 'get')
          res.status 404
        else
          res.status 405
        res.send()

      app.use (err, req, res, next) ->
        res.status err.status || 500
        res.send err.message

      callback err, app

module.exports = bootstrap