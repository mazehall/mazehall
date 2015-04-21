rewire = require 'rewire'
assert = require 'assert'
expect = require('chai').expect
mazehall = rewire '../lib/mazehall'
express = require 'express'
_r=  require 'kefir'

describe 'mazehall', ->
  describe 'components and environment logic', ->
    origEnv = process.env
    afterEach ->
      process.env = origEnv

    it 'should set core as default module component', (done) ->
      assert.deepEqual [''], mazehall.getComponentMask()
      done()

    it 'should set module components from MAZEHALL_COMPONENTS env', (done) ->
      process.env.MAZEHALL_COMPONENTS = 'ui,admin'
      assert.deepEqual ['ui', 'admin'], mazehall.getComponentMask()
      done()

    it 'should set all to core if core in MAZEHALL_COMPONENTS', (done) ->
      process.env.MAZEHALL_COMPONENTS = 'ui,core,admin'
      assert.deepEqual [''], mazehall.getComponentMask()
      done()

    it 'should register "cloud" tagged components only', (done) ->
      process.env.MAZEHALL_COMPONENTS = 'cloud,fake'
      mazehall.loadStream {appModuleSource: 'test/fixtures/test_modules'}
      stream = mazehall.moduleStream
      stream.onValue (x) ->
        expect ['admin', 'restapi']
        .to.include x.module
      counterValue = stream.scan (sum, x) ->
        return sum + 1
      , 0
      counterValue.onValue (x) ->
        done() if x is 2
      stream.onError (e) ->
        done(e)


  describe 'express integration', ->
    app = null
    beforeEach ->
      app = express()

    it 'should throw an error without first argument', (done) ->
      assert.throws () ->
        mazehall.initExpress()
      , /first argument/
      done()

    it 'should call the useRouting api with express object', (done) ->
      moduleStub =
        useRouting: (test) ->
          expect(test).to.equal(app)
          expect(test).itself.to.respondTo('use')
          done()
      mazehall.loadStream = () ->
        _r.constant moduleStub
      mazehall.initExpress(app)

    it "should call the 'done' function inside a loaded plugin", (done) ->
      app.set "done", done
      mazehall.initPlugins app, false, {pluginSource: "test/fixtures/test_plugins"}

  describe "database connection", ->

    beforeEach -> mazehall = rewire "../lib/mazehall"

    it "should return a singleton", (done) ->
      instance1 = require "../src/models/dataprovider"
      instance1.p = 1
      instance2 = require "../src/models/dataprovider"
      instance2.p = 2

      done assert.notEqual instance1.p, instance2.p-1

    it "should listen to cursor event 'data' when sync is true active", (done) ->
      caller = 0
      values = {modules: {module_1: {name: "module_1"}, module_2: {name: "module_2"}}}
      stream = mazehall.loadPluginStream {appModuleSource: "test/fixtures/test_plugins"}
      mazehall.__set__ "mazehall.loadPluginStream", -> stream
      mazehall.__set__ "modelplugin.tailCursor", ->
        caller++
        values
      mazehall.__set__ "_r",
        fromEvent: (target, event) ->
          caller++
          expect(target).to.deep.equal values
          assert.equal event, "data"
          @onValue = -> caller++
          @

      mazehall.setDatabase "mongodb", "mongodb://localhost/"
      mazehall.initPlugins express(), true

      done assert.equal caller, 3

    it "should throw an error when using database without provider info", (done) ->
      assert.throws ->
        require("./models/plugin").tailCursor()
      , Error
      done()

    it "should save provider info when is set over setDatabase", (done) ->
      providerInfo = {name: "test", opts: {"key": "value"}}
      mazehall.setDatabase providerInfo.name, providerInfo.opts
      dataprovider = require "../lib/models/dataprovider"

      expect(providerInfo).to.deep.equal dataprovider.getProvider()
      done()

  describe "plugin sync process", ->
    mazecli = null
    plugins = {}
    beforeEach ->
      mazehall = rewire "../lib/mazehall"
      mazecli  = rewire "../lib/cli"
      stream   = mazehall.loadPluginStream {appModuleSource: "test/fixtures/test_plugins"}
      mazecli.__set__ "console", log: -> return
      mazecli.__set__ "process", exit: -> return
      mazecli.__set__ "mazehall.getComponentMask", -> ["ui", "service"]
      mazecli.__set__ "mazehall.loadPluginStream", -> stream
      mazecli.__set__ "exports.installPlugin", -> return
      mazecli.__set__ "exports.removePlugin", -> return
      mazecli.__set__ "modelPlugin.addPlugin", (plugin, callback) -> callback? null, plugin
      mazecli.__set__ "fs.writeFile", -> return
      plugins = {
        "deployed_synced": {"version": "2.2.1","components": ["admin"]},
        "restapi": {"version": "0.1.0","components": ["api","service","cloud"]}
        "unregistered": {"version": "0.1.0","components": ["admin","cloud"]}
        "only-on-remote": {"version": "1.2.3","components": ["api","service","cloud"]}}

    it "should delete non database listed plugins", (done) ->
      mazecli.__set__ "exports.removePlugin", (name) ->
        done assert.equal name, "unregistered"
      delete plugins.unregistered

      mazecli.synchronizes plugins

    it "should install tagged component when not local exists", (done) ->
      mazecli.__set__ "exports.installPlugin", (name) ->
        done assert.equal name, "only-on-remote@1.2.3"

      mazecli.synchronizes plugins

    it "should change the deployment key to 'synced' when database was updated", (done) ->
      mazecli.__set__ "fs.writeFile", (path, data) ->
        json = JSON.parse data
        expect(data).to.match /deployed_local/
        expect(json).to.have.deep.property "mazehall_deployed", "synced"
        done()

      mazecli.__set__ "mazehall.getDatabase", ->
        @collection = (collection) ->
          @insert = (document, callback) ->
            expect(document).to.have.any.keys "deployed_local"
            callback null, document
          @find = (callback) -> callback null, {}
          return@
        return@

      mazecli.synchronizes plugins

    it "should update if different version between local and database", (done) ->
      mazecli.__set__ "mazehall.getComponentMask", -> ["newer"]
      mazecli.__set__ "exports.installPlugin", (name) ->
        done assert.equal name, "restapi@2.1.0"

      plugins.restapi.version    = "2.1.0"
      plugins.restapi.components = ["with", "newer", "version"]

      mazecli.synchronizes plugins

    it "should remove synced package when not in database exists", (done) ->
      mazecli.__set__ "exports.removePlugin", (name) ->
        done assert.equal name, "deployed_synced"
      delete plugins.deployed_synced

      mazecli.synchronizes plugins

    it "should update the database plugin when local version is greater", (done) ->
      local = require("util")._extend {}, plugins.restapi
      mazecli.__set__ "exports.databaseInsertPlugin", (plugin) ->
        assert.equal plugin.pkg.version, local.version
        done()

      plugins.restapi.version = "0.0.55"
      plugins.deployed_local = {version: "0.1.0", components: []}

      mazecli.synchronizes plugins

    it "should call the delete method when removing from database", (done) ->
      database = {provider: "mongodb", options: "mongodb://localhost/"}
      mazecli.__set__ "mazehall.setDatabase", (provider, options) ->
        assert.equal provider, database.provider
        assert.equal options, database.options
      mazecli.__set__ "modelPlugin.deletePlugin", (name) ->
        done assert.equal name, "restapi"

      mazecli.databaseRemovePlugin "restapi", database.provider, database.options

    it "should throw an error using syncing without provider info", (done) ->
      assert.throws ->
        mazehall.__set__ "require", -> return
        mazehall.initPlugins express(), true
      , Error
      done()

  describe "plugins", ->

    it "should throw an error when called init without argument", (done) ->
      assert.throws ->
        mazehall.initPlugins undefined
      , Error
      done()

    it "should load all four plugins from test directory", (done) ->
      included = 1
      mazehall.__set__ "require", (path) ->
        expect(path).to.include "test_plugins"
        included++
        done() if included is 4

      mazehall.initPlugins express(), false, {pluginSource: "test/fixtures/test_plugins"}