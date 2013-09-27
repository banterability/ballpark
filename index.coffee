app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

VOTE_OPTIONS = [0,1,2,3,5,8,'?']

server.listen 5678, ->
  console.log "up on http://localhost:5678"

app.get '/', (req, res) ->
  res.sendfile "#{__dirname}/index.html"

io.sockets.on 'connection', (socket) ->
  socket.emit 'connected',
    options: VOTE_OPTIONS

  socket.on 'vote', (data) ->
    console.log "User #{socket.id} voted:", data.vote
