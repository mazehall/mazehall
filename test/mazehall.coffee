rewire = require 'rewire'
assert = require 'assert'
expect = require('chai').expect
mazehall = rewire '../src/mazehall'
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

    it 'should call the module constructor with express object', (done) ->
      moduleStub = (test) ->
          expect(test).to.equal(app)
          expect(test).itself.to.respondTo('use')
          done()
      mazehall.loadStream = () ->
        _r.constant moduleStub
      mazehall.initExpress(app)

    it "should call the 'done' function inside a loaded plugin", (done) ->
      app.set "done", done
      mazehall.initPlugins app, {pluginSource: "test/fixtures/test_plugins"}

  describe "plugins", ->
    beforeEach ->
      mazehall = rewire "../src/mazehall"

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

      mazehall.initPlugins express(), {pluginSource: "test/fixtures/test_plugins"}
