// Generated by CoffeeScript 1.6.1
(function() {
  var port, redis, server;

  redis = require('haredis').createClient([6380, 6381, 6382]);

  redis.debug_mode = true;

  server = require('net').createServer(function(c) {
    return c.on('end', function() {
      return process.exit();
    });
  });

  port = process.env.PORT || 3000;

  server.listen(port, function() {
    return console.log("close a connection on port " + port + " to terminate");
  });

}).call(this);