rewire = require("rewire")
assert = require("assert")
expect = require("chai").expect


describe "cli mazehall", ->
  mazecli = null


  beforeEach ->
    mazecli = rewire("../lib/cli");

#  it "should apply the new module in the 'cwd' with over ten files", (done) ->
#    modulename = "testModule"
#    workingdir = "/dev/null/"
#    targetpath = "#{workingdir}app_modules/#{modulename}"
#    hasWritten = []
#    WritteData = (path) ->
#      assert.notEqual path.indexOf(targetpath), -1
#      hasWritten.push path
#
#    mazecli.__set__ "process",
#      cwd: -> workingdir
#      exit: -> return
#      platform: "linux"
#    mazecli.__set__ "console",
#      log: -> return
#    mazecli.__set__ "fs",
#      writeFile: WritteData
#      mkdirSync: WritteData
#      existsSync:() -> true
#
#    mazecli.createAppModule undefined, modulename
#    expect(hasWritten).to.have.length.of.at.least(10);
#    done()

  it "should create 'app_modules' folder when not available", (done) ->
    mazecli.__set__ "shell", exec: -> return null
    mazecli.__set__ "console",
      log: -> return
    mazecli.__set__ "fs",
      writeFile:() -> return
      mkdirSync:(path) -> assert.equal path, "/dev/null/app_modules"
      existsSync:() -> return

    mazecli.createMazeApp "/dev/null"
    done()

  it "should create 3 files in the target folder: server.js, app.js and package.json", (done) ->
    hasWritten = [];
    mazecli.__set__ "shell", exec: -> return null
    mazecli.__set__ "console",
      log: -> return
    mazecli.__set__ "fs",
      writeFile:(path) -> hasWritten.push path
      mkdirSync:() -> return
      existsSync:() -> return

    mazecli.createMazeApp "/dev/null"
    expect(hasWritten.length).to.equal(3);
    expect(hasWritten).to.deep.equal(["/dev/null/app.js", "/dev/null/server.js", "/dev/null/package.json"]);
    done()

  it "should exit the process when a app already exists and not forced", (done) ->
    mazecli.isAppInstalled =  -> false
    mazecli.__set__ "console",
      log: -> return
    mazecli.__set__ "process",
      cwd: -> "/dev/null/testApp1"
      exit: -> expect(arguments).to.be.empty
    mazecli.__set__ "shell", exec: -> return null
    mazecli.__set__ "fs",
      writeFile:(path) -> return
      mkdirSync:(path) -> return
      existsSync:(path) -> return

    mazecli.createMazeApp "/dev/null"
    done()
  describe "helpers", ->

    it "should true when the directory has an package.json", (done) ->
      mazecli.__set__ "fs", existsSync: (path) -> path == "/dev/null/package.json"

      assert.equal mazecli.isAppInstalled("/dev/null"), true
      done()

    it "should return the name of 'cwd' when no argument given", (done) ->
      mazecli.__set__ "process", cwd: -> "/dev/null/testApp"

      assert.equal mazecli.getDirectoryName(), "testApp"
      done()

    it "should return the name of current directory", (done) ->
      mazecli.__set__ "process", platform: "win32"

      assert.equal mazecli.getDirectoryName("d:\\windows\\testApp"), "testApp"
      done()

    it "should return appname from the 'cwd' when no arguments given", (done) ->
      mazecli.__set__ "process",
        cwd: -> "/dev/null/testApp"
        platform: "linux"

      assert.equal mazecli.getAppName(), "testApp"
      done()

    it "should return appname from the first given program argument", (done) ->
      mazecli.__set__ "program", args: ["testApp", "arg2"]

      assert.equal mazecli.getAppName(), "testApp"
      done()



