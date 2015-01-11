rewire = require 'rewire'
assert = require 'assert'
expect = require('chai').expect
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
        mazehall.initExpress()
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

    it 'should register routes'
