app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
{reduce, last} = require 'underscore'
uuid = require 'node-uuid'


VOTE_OPTIONS = [0,1,2,3,5,8]
ELECTIONS = []

server.listen 5678, ->
  console.log "up on http://localhost:5678"

app.get '/', (req, res) ->
  res.sendfile "#{__dirname}/index.html"

io.sockets.on 'connection', (socket) ->

  ws = new Websocket socket, io

  if ELECTIONS.length > 0
    election = last ELECTIONS
  else
    election = createElection()

  ws.reply 'connected',
    options: VOTE_OPTIONS
    userCount: ws.clientCount()
    election: election.id

  broadcastUserCount ws, 'connect'

  ws.socket.on 'vote', (data) ->
    election = getElection data.election
    election.vote data.vote

    ws.broadcast 'newVote',
      option: data.vote
      userId: ws.socketId()
      summary: election.summary()

  ws.socket.on 'disconnect', ->
    broadcastUserCount ws, 'disconnect'

  ws.socket.on 'resetVote', ->
    newElection = createElection()

    ws.broadcast 'newElection',
      electionId: newElection.id


## Helpers ##

broadcastUserCount = (ws, eventType) ->
  userCount = ws.clientCount()
  userCount -= 1 if eventType is "disconnect"

  ws.notify 'userChange',
    userId: ws.socketId()
    userCount: userCount
    eventType: eventType

createElection = ->
  election = new Election()
  ELECTIONS[election.id] = election
  election

getElection = (id) ->
  ELECTIONS[id]

class Election
  constructor: () ->
    @id = uuid.v1()
    @votes = []

  vote: (value) ->
    @votes.push parseInt(value, 0)

  summary: ->
    sum = reduce @votes, (memo, num) ->
      memo + num
    , 0
    count = @votes.length

    return {
      electionId: @id
      sum: sum
      count: count
      avg: sum / count
    }

class Websocket
  constructor: (@socket, @io) ->

  socketId: ->
    @socket.id

  # count of attached clients
  clientCount: ->
    @io.sockets.clients().length

  # send message back to sender
  reply: (msg, data) ->
    @socket.emit msg, data

  # send message to everyone *but* sender
  notify: (msg, data) ->
    @socket.broadcast.emit msg, data

  # send message to all
  broadcast: (msg, data) ->
    @io.sockets.emit msg, data
