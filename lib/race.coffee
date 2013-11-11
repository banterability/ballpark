{reduce} = require 'underscore'
uuid = require 'node-uuid'


class Race
  constructor: (@store) ->
    @id = uuid.v1()
    @key = "races:#{@id}:votes"

  vote: (value) ->
    @store.rpush @key, value

  summary: ->
    total = @_total()
    count = @_count()

    return {
      id: @id
      total: total
      count: count
      avg: total/count
    }

  _results: ->
    @store.lrange @key, 0, -1

  _total: ->
    reduce @_results(), (memo, num) ->
      memo + num
    , 0

  _count: ->
    @store.llen @key


module.exports = Race
