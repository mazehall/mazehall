rewire = require 'rewire'
modules = rewire '../lib/modules'
assert = require 'assert'
_r = require 'kefir'
fs = require 'fs'


describe 'dirEmitter', (done) ->

  it 'should emit error and end if dir not found', (done) ->
    testStream = _r.fromBinder modules.dirEmitter()
    testStream.onError (x) ->
      assert.equal 'ENOENT', x.code
    testStream.onEnd () ->
      done()

  it 'should emit dir names from fixtures', (done) ->
    testStream = _r.fromBinder modules.dirEmitter('test/fixtures/test_modules')
    .map (x) -> x.module
    .bufferWhile()
    testStream.onValue (x) ->
      assert.deepEqual x, ["admin","api","emptycomponents","ui"]
    testStream.onEnd () ->
      done()

  it 'should load package.json files', (done) ->
    testStream = _r.fromBinder modules.dirEmitter('test/fixtures/test_modules')
    dirValue =
      path: 'test/fixtures/test_modules/admin'

    packagesStream = modules.readPackageJson dirValue
    .bufferWhile()
    packagesStream.onValue (x) ->
      assert.equal x[0].pkg.name, 'admin'
    packagesStream.onEnd () ->
      done()

  it 'should emit error on fs crashes', (done) ->
    fsFake =
      readFile: (p, cb) ->
        cb new Error 'fs crash'
    modules.__set__ 'fs', fsFake
    dirValue =
      path: 'fake'
    packagesStream = modules.readPackageJson dirValue
    .bufferWhile()
    values = []
    packagesStream.onError (x) ->
      values.push 1
    packagesStream.onEnd () ->
      assert.equal 1, values.length
      done()