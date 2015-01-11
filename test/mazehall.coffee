rewire = require 'rewire'
assert = require 'assert'
request = require 'supertest'
mazehall = rewire '../lib/mazehall'
express = require 'express'
_r=  require 'kefir'

describe 'mazehall', ->
  describe 'components and environment logic', ->
    origEnv = process.env
    afterEach ->
      process.env = origEnv

    it 'should throw an error without first argument', (done) ->
      assert.throws () ->
        mazehall.init()
      , /first argument/
      done()

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
      stream = mazehall.init express(), {appModuleSource: 'test/fixtures/test_modules'}
      counterValue = stream.scan (sum, x) ->
        return sum + 1
      , 0
      counterValue.onValue (x) ->
        done() if x is 2
      stream.onValue (x) ->
        if x.module not in ['admin', 'restapi']
          assert.fail x.module + ' module not to be expected'
          done()
      stream.onError (e) ->
        assert.fail(e)


  describe 'express integration', ->
    app = null
    beforeEach ->
      app = express()

    it 'should register routes'
