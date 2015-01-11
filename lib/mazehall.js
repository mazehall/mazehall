var isPackageEnabled, mazehall, modules, _r,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

modules = require('./modules');

_r = require('kefir');

mazehall = {};

mazehall.getComponentMask = function() {
  var components;
  components = (process.env.MAZEHALL_COMPONENTS || '').split(",");
  if ((components.indexOf("core")) >= 0) {
    components = [''];
  }
  return components;
};

mazehall.init = function(app, options) {
  var componentMask, directoryStream, mazehallStream, packagesStream, responseStream;
  if (options == null) {
    options = {};
  }
  if (!app) {
    throw new Error('first argument "app" required');
  }
  componentMask = mazehall.getComponentMask();
  directoryStream = _r.fromBinder(modules.dirEmitter(options.appModuleSource ? options.appModuleSource : void 0));
  packagesStream = directoryStream.flatMap(modules.readPackageJson).filter(function(x) {
    return x.pkg.mazehall;
  });
  mazehallStream = packagesStream.filter(isPackageEnabled(componentMask));
  mazehallStream.onValue(function(module) {
    var _m;
    _m = require(module.path);
    if (typeof _m.usePreRouting === "function") {
      _m.usePreRouting(app);
    }
    if (typeof _m.useRouting === "function") {
      _m.useRouting(app);
    }
    return typeof _m.usePostRouting === "function" ? _m.usePostRouting(app) : void 0;
  });
  responseStream = _r.bus();
  responseStream.plug(mazehallStream.map(function(e) {
    return {
      module: e.pkg.name,
      components: e.pkg.components
    };
  }));
  return responseStream;
};

isPackageEnabled = function(mask) {
  return function(item) {
    var enabler, _base;
    if ((_base = item.pkg).components == null) {
      _base.components = [];
    }
    item.pkg.components.push('');
    return __indexOf.call((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = mask.length; _i < _len; _i++) {
        enabler = mask[_i];
        _results.push(__indexOf.call(item.pkg.components, enabler) >= 0);
      }
      return _results;
    })(), true) >= 0;
  };
};

module.exports = mazehall;
