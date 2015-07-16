rewire = require("rewire")
assert = require("assert")
expect = require("chai").expect

describe "models", ->

  describe "plugin", ->

    it "should call the function getPlugin from the dataprovider", (done) ->
      modelplugin = rewire "../src/models/plugin"
      dataprovider = rewire "../src/models/dataprovider"
      dataprovider.setProvider "dummy"
      dataprovider.__set__ "module.exports.getPlugin", ->
        return -> initSync : -> done()
      modelplugin.__set__ "module.exports.provider", dataprovider.getPlugin()

      modelplugin.initSync()

  describe "dataprovider", ->
    dataprovider = null
    beforeEach ->
      dataprovider = rewire "../src/models/dataprovider"
      dataprovider.setProvider dummyProvider.name, dummyProvider.opts
    dummyProvider =
      name : "dummy"
      opts : "dummy://foo.tld/"

    it "should save the provider property in self", (done) ->
      expect(dataprovider.providers).to.have.any.keys(dummyProvider.name);
      assert.deepEqual dummyProvider, dataprovider.providers[dummyProvider.name]
      done()

    it "should return the last value set as object", (done) ->
      expect(dataprovider.getProvider()).to.be.an "object"
      assert.deepEqual dummyProvider, dataprovider.getProvider()
      done()

    it "should load the new model file when not cached", (done) ->
      dataprovider.__set__ "require", (file) ->
        ->
          expected = "./dummy/plugin"
          assert.equal expected, file
          done()

      dataprovider.getPlugin()

    it "should return the cached model when already loaded", (done) ->
      orgLoadModel = dataprovider.__get__ "loadModel"
      moduleLoaded = 0
      dataprovider.__set__ "require", -> -> return -> return
      dataprovider.__set__ "loadModel", (model) ->
        moduleLoaded++
        orgLoadModel model

      dataprovider.getPlugin()
      dataprovider.getPlugin()

      assert.equal moduleLoaded, 1
      done()

    it "should throw an error when call setter without arguments", (done) ->
      assert.throws ->
        dataprovider.setProvider undefined
      , Error
      done()

    it "should throw an error when load model without provider", (done) ->
      dataprovider.providers = dataprovider.instances = {}
      assert.throws ->
        dataprovider.getPlugin()
      , Error
      done()

    it "should throw an error when call getter whit non provider", (done) ->
      dataprovider.providers = dataprovider.instances = {}
      assert.throws ->
        dataprovider.getProvider()
      , Error
      done()