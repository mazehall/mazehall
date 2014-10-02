jwt = require 'jsonwebtoken'

authOnEvent = (options, callback) ->
  (socket) ->
    server = this

    auth_timeout = setTimeout(->
      callback "unauthorized", socket if callback
      return
    , options.timeout or 5000)

    socket.on "authenticate", (data) ->
      clearTimeout auth_timeout

      unless data?.token?
        return callback "invalid data", socket if callback

      jwt.verify data.token, options.secret, options, (err, decoded) ->
        if err
          callback "unauthorized", socket if callback
          return

        socket.decoded_token = decoded
        callback null, socket if callback
      return

    return

exports.authOnEvent = authOnEvent