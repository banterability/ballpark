{reduce} = require 'underscore'
uuid = require 'node-uuid'
async = require 'async'


class Race
  constructor: (@store) ->
    @id = uuid.v1()
    @key = "races:#{@id}:votes"

  vote: (value) ->
    @store.rpush @key, value

  summary: (cb) ->
    async.parallel {
      total: @_total
      count: @_count
    }, (err, results) =>
      cb err, {
        id: @id
        total: results.total
        count: results.count
        avg: results.total / results.count
      }

  _results: (cb) ->
    results = @store.lrange @key, 0, -1, (err, res) ->
      cb err, res

  _total: (cb) =>
    @_results (err, res) ->
      cb null, reduce res, (memo, num) ->
        memo + parseInt num, 10
      , 0

  _count: (cb) =>
    @store.llen @key, (err, res) ->
      cb err, res


module.exports = Race
