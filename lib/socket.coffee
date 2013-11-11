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


module.exports = Websocket