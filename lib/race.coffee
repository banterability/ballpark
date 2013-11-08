{reduce} = require 'underscore'
uuid = require 'node-uuid'


class Race
  constructor: (@store) ->
    @id = uuid.v1()
    @key = "races:#{@id}:votes"

  vote: (value) ->
    @store.rpush @key, value

  total: ->
    reduce @_results(), (memo, num) ->
      memo + num
    , 0

  _results: ->
    @store.lrange @key, 0, -1

  # summary: ->
  #   sum = reduce @votes, (memo, num) ->
  #     memo + num
  #   , 0
  #   count = @votes.length

  #   return {
  #     electionId: @id
  #     sum: sum
  #     count: count
  #     avg: sum / count
  #   }


module.exports = Race
