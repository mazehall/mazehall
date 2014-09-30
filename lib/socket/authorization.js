(function() {
  var authOnEvent, jwt;

  jwt = require('jsonwebtoken');

  authOnEvent = function(options, callback) {
    return function(socket) {
      var auth_timeout, server;
      server = this;
      auth_timeout = setTimeout(function() {
        if (callback) {
          callback("unauthorized", socket);
        }
      }, options.timeout || 5000);
      socket.on("authenticate", function(data) {
        clearTimeout(auth_timeout);
        if ((data != null ? data.token : void 0) == null) {
          if (callback) {
            return callback("invalid data", socket);
          }
        }
        jwt.verify(data.token, options.secret, options, function(err, decoded) {
          if (err) {
            if (callback) {
              callback("unauthorized", socket);
            }
            return;
          }
          socket.decoded_token = decoded;
          if (callback) {
            return callback(null, socket);
          }
        });
      });
    };
  };

  exports.authOnEvent = authOnEvent;

}).call(this);
