app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
{reduce, last} = require 'underscore'


VOTE_OPTIONS = [0,1,2,3,5,8]
ELECTIONS = []
ELECTION_ID = 0

server.listen 5678, ->
  console.log "up on http://localhost:5678"

app.get '/', (req, res) ->
  res.sendfile "#{__dirname}/index.html"

io.sockets.on 'connection', (socket) ->
  if ELECTIONS.length > 0
    election = last ELECTIONS
  else
    election = createElection()

  socket.emit 'connected',
    options: VOTE_OPTIONS
    userCount: io.sockets.clients().length
    election: election.id

  broadcastUserCount socket, 'connect'

  socket.on 'vote', (data) ->
    election = ELECTIONS[ELECTION_ID]
    election.vote data.vote
    io.sockets.emit 'newVote',
      option: data.vote
      userId: socket.id
      summary: election.summary()

  socket.on 'disconnect', ->
    broadcastUserCount socket, 'disconnect'

  socket.on 'resetVote', ->
    ELECTION_ID += 1
    newElection = new Election(ELECTION_ID)
    ELECTIONS[ELECTION_ID] = newElection

    io.sockets.emit 'newElection',
      electionId: ELECTION_ID


## Helpers ##

broadcastUserCount = (socket, eventType) ->
  userCount = io.sockets.clients().length
  userCount -= 1 if eventType is "disconnect"

  socket.broadcast.emit 'userChange',
    userId: socket.id
    userCount: userCount
    eventType: eventType

createElection = ->
    ELECTION_ID += 1
    newElection = new Election(ELECTION_ID)
    ELECTIONS[ELECTION_ID] = newElection
    newElection

class Election
  constructor: (@id) ->
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
