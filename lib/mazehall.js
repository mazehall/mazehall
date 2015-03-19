var _r, isPackageEnabled, mazehall, modules,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

modules = require('./modules');

_r = require('kefir');

mazehall = {};

mazehall.moduleStream = _r.bus();

mazehall.getComponentMask = function() {
  var components;
  components = (process.env.MAZEHALL_COMPONENTS || '').split(",");
  if ((components.indexOf("core")) >= 0) {
    components = [''];
  }
  return components;
};


/* events in time

  mazehallStream
  directory:   --d---d--|
  dirEmitter:    D---D--|     {module:'x',path:'<modulePath>'}
  .flatMap:      -Dp---Dp-|   {module:'x',path:'<modulePath>',pkg:{<package.json>}}
  .filter:       -Dp---Dp-|   mazehall:true
  .filter:       -Dp------|   componentMask
  return:         M-------|

  moduleStream ---m---------  {module:'x',components:['a','']}
 */

mazehall.loadStream = function(options) {
  var componentMask, directoryStream, mazehallStream, packagesStream;
  if (options == null) {
    options = {};
  }
  componentMask = mazehall.getComponentMask();
  directoryStream = _r.fromBinder(modules.dirEmitter(options.appModuleSource ? options.appModuleSource : void 0));
  packagesStream = directoryStream.flatMap(modules.readPackageJson).filter(function(x) {
    return x.pkg.mazehall;
  }).filter(isPackageEnabled(componentMask));
  mazehallStream = packagesStream.map(function(module) {
    return require(module.path);
  });
  mazehall.moduleStream.plug(packagesStream.map(function(e) {
    return {
      module: e.pkg.name,
      components: e.pkg.components
    };
  }));
  return mazehallStream;
};

mazehall.initExpress = function(app, options) {
  if (options == null) {
    options = {};
  }
  if (!app) {
    throw new Error('first argument "app" required');
  }
  return mazehall.loadStream(options).onValue(function(module) {
    return typeof module.useRouting === "function" ? module.useRouting(app) : void 0;
  });
};

isPackageEnabled = function(mask) {
  return function(item) {
    var base, enabler;
    if ((base = item.pkg).components == null) {
      base.components = [];
    }
    item.pkg.components.push('');
    return indexOf.call((function() {
      var i, len, results;
      results = [];
      for (i = 0, len = mask.length; i < len; i++) {
        enabler = mask[i];
        results.push(indexOf.call(item.pkg.components, enabler) >= 0);
      }
      return results;
    })(), true) >= 0;
  };
};

module.exports = mazehall;
