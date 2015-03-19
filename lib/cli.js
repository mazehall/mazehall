var fs, program, shell;

program = require("commander");

shell = require("shelljs");

fs = require("fs");


/**
 * Creates a new module skeleton
#
 * @param  {string} path
 * @param  {string} modulename
 * @param  {string} [program]
 */

exports.createAppModule = function(path, modulename, program) {
  var applyFiles, skeleton, template;
  path = typeof path === "undefined" ? (process.cwd()) + "/" : path;

  /** creates a 'app_modules' folder when not present * */
  if (this.isAppModulesExists() === false) {
    console.log("   \u001b[33m" + "warn" + "\u001b[0m  : folder app_modules is not yet exists");
    this.createDir(path + "/app_modules");
  }

  /** stop when the target directory already exists and not forced * */
  if (this.hasAppModule(modulename) && (program != null ? program.force : void 0) !== true) {
    console.log("   \u001b[31m" + "error" + "\u001b[0m : module already " + modulename + " exists");
    process.exit();
  }
  template = this.template.modules;
  skeleton = {
    ".gitignore": template.gitignore(),
    ".bowerrc": template.bowerrc(),
    "package.json": template.package_json(),
    "index.js": template.index_js(),
    "gulpfile.js": "",
    "bower.json": template.bower_json(),
    "public": this.createDir,
    "public/src": this.createDir,
    "public/src/index.html": "",
    "public/src/css": this.createDir,
    "public/src/css/app.css": "",
    "public/src/js": this.createDir,
    "public/src/js/mazehallApp.js": "'use strict';",
    "public/src/js/controller": this.createDir,
    "public/src/templates": this.createDir
  };
  console.log("   \u001b[32m" + "create:" + "\u001b[0m " + modulename + " module");
  applyFiles = function(path) {
    var filename;
    for (filename in skeleton) {
      if (skeleton[filename] && typeof skeleton[filename] === "function") {
        skeleton[filename].call(null, path + filename);
      }
      if (typeof skeleton[filename] === "string") {
        exports.writeFile(path + filename, skeleton[filename]);
      }
    }
  };
  if (!this.hasAppModule(modulename)) {
    this.createDir(path + "app_modules/" + modulename + "/", function(path) {
      return applyFiles(path);
    });
  } else {
    applyFiles(path + "app_modules/" + modulename + "/");
  }

  /** install package dependencies * */
  return shell.exec("cd " + path + " && npm install serve-static --save", function(err) {
    if (err) {
      console.log(err);
    }
    console.log("\n\u001b[32m" + ("mazehall module " + modulename + " was created!") + "\u001b[0m");
    return console.log("\n -> " + path + "app_modules/" + modulename + "\n");
  });
};


/**
 * Creates an new Mazehall app
#
 * @param  {string} [path = process.cwd()]
 * @param  {object} [program]
 */

exports.createMazeApp = function(path, program) {
  path = typeof path === "undefined" ? (process.cwd()) + "/" : path;

  /** exit, when an application already exists and not forced * */
  if (this.isAppInstalled() && (program != null ? program.force : void 0) !== true) {
    console.log("   \u001b[31m" + "error" + "\u001b[0m : app.js or package.json already exists");
    process.exit();
  }
  console.log("   \u001b[32m" + "create:" + "\u001b[0m " + (this.getAppName()));
  if (this.isAppModulesExists() !== false) {
    this.createDir(path + "/app_modules");
  }
  this.writeFile(path + "/app.js", this.template.coreapp.app_js());
  this.writeFile(path + "/server.js", this.template.coreapp.server_js());
  this.writeFile(path + "/package.json", this.template.coreapp.package_json(), function() {

    /** install package dependencies * */
    return shell.exec("cd " + path + " && npm install mazehall express --save", function(err) {
      if (err) {
        console.log(err);
      }
      console.log("\n\u001b[32m" + "mazehall application was created!" + "\u001b[0m");
      return console.log("\n -> " + path + "\n");
    });
  });
};


/**
 * Writes data to a file asynchronously
#
 * @param {string} path
 * @param {string} buffer
 * @param {function(string):void} [callback]
 */

exports.writeFile = function(path, buffer, callback) {
  var e;
  try {
    return fs.writeFile(path, buffer, function() {
      console.log("   \u001b[32m" + "write" + "\u001b[0m : " + path);
      return callback && callback.call(null, path);
    });
  } catch (_error) {
    e = _error;
    if (e.code !== "EEXIST") {
      throw e;
    }
  }
};


/**
 * Creates a non recursive directory
#
 * @param {string} path
 * @param {function(string):void} [callback]
 */

exports.createDir = function(path, callback) {
  var e;
  try {
    fs.mkdirSync(path);
    console.log("   \u001b[36m" + "mkdir" + "\u001b[0m : " + path);
    return callback && callback(path);
  } catch (_error) {
    e = _error;
    if (e.code !== "EEXIST") {
      throw e;
    }
  }
};


/**
 * Returns the name of Directory
#
 * @param  {string} [path = process.cwd()]
 * @return {string}
 */

exports.getDirectoryName = function(path) {
  var filename, resolved;
  filename = typeof path === "undefined" ? process.cwd() : path;
  resolved = filename.split(process.platform === "win32" ? "\\" : "/");
  return resolved[resolved.length - 1];
};


/**
 * Return the name of the new Mazehall app
#
 * @return {string}
 */

exports.getAppName = function() {

  /** name from program argument or current directory name * */
  if ((program.args == null) || program.args.length === 0) {
    return this.getDirectoryName();
  } else {
    return program.args[0];
  }
};


/**
 * Checks if an app already exists
#
 * @param  {string} [path = process.cwd()]
 * @return {boolean}
 */

exports.isAppInstalled = function(path) {
  path = typeof path === "undefined" ? process.cwd() : path;
  return fs.existsSync((path + "/app.js") && (path + "/package.json"));
};


/**
 * Checks if app_modules exists
#
 * @param  {string} [path = process.cwd()]
 * @return {boolean}
 */

exports.isAppModulesExists = function(path) {
  path = typeof path === "undefined" ? process.cwd() : path;
  return fs.existsSync((path + "app_modules") && (path + "/app_modules"));
};


/**
 * Checks if the named module already exists
#
 * @param  {string} modulename
 * @return {boolean}
 */

exports.hasAppModule = function(modulename) {
  return fs.existsSync((process.cwd()) + "/app_modules/" + modulename);
};


/**
#
 * Template Generators
#
 * @type {{coreapp: {package_json: Function, app_js: Function}, modules: {bowerrc: Function, gitignore: Function, bower_json: Function, index_js: Function, package_json: Function}}}
 */

exports.template = {

  /**
   * @type object
   */
  coreapp: {

    /**
     * Template : package.json
    #
     * @return {string}
     */
    package_json: function() {
      var template;
      template = {
        "name": exports.getAppName(),
        "version": "0.1.0",
        "license": "MIT",
        "private": true,
        "main": "server.js",
        "description": "mazehall application",
        "author": 'Mazehall Generator',
        "contributors": [
          {
            "name": "#"
          }
        ],
        "repository": "#"
      };
      return JSON.stringify(template, null, 2);
    },

    /**
     * Template : app.js
    #
     * @return {string}
     */
    app_js: function() {
      var content;
      content = 'var mazehall = require(\'mazehall\');\n' + 'var express = require(\'express\');\n' + '\n' + 'var app, server;\n' + 'app = express();\n' + 'server = require(\'http\').Server(app);\n' + 'mazehall.moduleStream.log(\'module loader\');\n' + 'mazehall.initExpress(app);\n' + 'module.exports = server;';
      return content;
    },

    /**
     * Template : server.js
    #
     * @return {string}
     */
    server_js: function() {
      var content;
      content = 'var server = require(\'./app.js\');\n' + '\n' + 'var port;\n' + 'port = process.env.PORT || 3000\n' + 'server.listen(port, function() {\n' + '  console.log(\'server listen on port: \' + port);\n' + '});';
      return content;
    }
  },

  /**
   * @type object
   */
  modules: {

    /**
     * Template : .bowerrc
    #
     * @return {string}
     */
    bowerrc: function() {
      var template;
      template = {
        "directory": "public/src/bower_components"
      };
      return JSON.stringify(template, null, 2);
    },

    /**
     * Template : .gitignore
    #
     * @return {string}
     */
    gitignore: function() {
      return "\n.zedstate" + "\nnode_modules" + "\n.idea" + "\npublic/dist" + "\npublic/src/bower_components";
    },

    /**
     * Template : bower.json
    #
     * @return {string}
     */
    bower_json: function() {
      var template;
      template = {
        "name": exports.getAppName(),
        "version": "0.1.0",
        "private": true,
        "authors": ["Mazehall Generator"],
        "description": "example for the mazehall framework",
        "license": "MIT"
      };
      return JSON.stringify(template, null, 2);
    },

    /**
     * Template : index.js
    #
     * @return {string}
     */
    index_js: function() {
      var template;
      template = function() {
        var path, serveStatic;
        path = require("path");
        serveStatic = require("serve-static");
        module.exports = {
          useRouting: function(app) {
            var env;
            env = process.env.NODE_ENV || "development";
            app.use(serveStatic(path.join(__dirname, env === "development" ? "public/src" : "public/dist")));
          }
        };
      };
      return "(" + (template.toString()) + ").call(this);";
    },

    /**
     * Template : package.json
    #
     * @return {string}
     */
    package_json: function() {
      var template;
      template = {
        "name": exports.getAppName(),
        "version": "0.1.0",
        "private": true,
        "description": "module",
        "main": "index.js",
        "mazehall": true,
        "components": ["ui"],
        "author": "Mazehall Generator",
        "contributors": [
          {
            "name": "#"
          }
        ]
      };
      return JSON.stringify(template, null, 2);
    }
  }
};
