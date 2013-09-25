app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
uuid = require 'node-uuid'

server.listen 5678, ->
  console.log "up on http://localhost:5678"

app.get '/', (req, res) ->
  res.sendfile "#{__dirname}/index.html"

io.sockets.on 'connection', (socket) ->
  userId = uuid.v1()
  socket.set 'userId', userId, ->
    socket.emit 'connected', id: userId

  socket.on 'vote', (data) ->
    socket.get 'userId', (err, userId) ->
      console.log "User #{userId} voted:", data.vote
