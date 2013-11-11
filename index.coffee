app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
{reduce, last} = require 'underscore'
uuid = require 'node-uuid'
redis = require 'redis'
client = redis.createClient()
Race = require './lib/race'


VOTE_OPTIONS = [0,1,2,3,5,8]
CURRENT_ELECTION = null

server.listen 5678, ->
  console.log "up on http://localhost:5678"

app.get '/', (req, res) ->
  res.sendfile "#{__dirname}/index.html"

io.sockets.on 'connection', (socket) ->

  ws = new Websocket socket, io

  CURRENT_ELECTION = createElection() unless CURRENT_ELECTION

  ws.reply 'connected',
    options: VOTE_OPTIONS
    userCount: ws.clientCount()
    election: CURRENT_ELECTION.id

  broadcastUserCount ws, 'connect'

  ws.socket.on 'vote', (data) ->
    election = CURRENT_ELECTION
    election.vote data.vote

    election.summary (err, summary) ->
      ws.broadcast 'newVote',
        option: data.vote
        userId: ws.socketId()
        summary: summary

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
  CURRENT_ELECTION = new Race client

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
