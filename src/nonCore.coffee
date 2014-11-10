modules = require './modules'
aggregate = require "./aggregate"

bootstrap = (app, components, callback) ->
  console.log 'bootstrap non core'

  modules.findModules (err, foundModules) ->
    console.log 'loading mazehall modules failed' if err
    return callback err if err

    modules.enableModulesByComponents components, (err, result) ->
      console.log 'enabling mazehall modules failed' if err
      return callback err if err

      #run aggregate
      modules.aggregateAsset()

      #run routing callbacks
      modules.runPreRoutingCallbacks app

      app.get "/modules/aggregated.js", (req, res) ->
        res.setHeader "content-type", "text/javascript"
        aggregate.aggregated "js", (if req.query.group then req.query.group else "footer"), (data) ->
          res.send data

      app.get "/modules/aggregated.css", (req, res) ->
        res.setHeader "content-type", "text/css"
        aggregate.aggregated "css", (if req.query.group then req.query.group else "header"), (data) ->
          res.send data

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