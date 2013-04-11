redis = require('haredis').createClient [6380, 6381, 6382]
redis.debug_mode = true

server = require('net').createServer (c) ->
  c.on 'end', ->
    process.exit()
port = process.env.PORT || 3000
server.listen port, ->
  console.log "close a connection on port #{port} to terminate"
