assert = require 'assert'
Race = require '../lib/race'
bond = require 'bondjs'

describe "Race", ->
  it "sets a UUID on construction", ->
    race = new Race
    assert race.id

  describe "#vote", ->
    beforeEach ->
      @store =
        rpush: bond()
      @race = new Race @store

    it 'records the vote in the proper store', ->
      expectedKey = "races:#{@race.id}:votes"
      @race.vote 1

      assert @store.rpush.calledWith expectedKey, 1

  describe "#summary", ->
    beforeEach ->
      @store =
        lrange: bond().return [1,2,3,4]
        llen: bond().return 4
      @race = new Race @store

    it 'returns a sum of all votes', ->
      expectedKey = "races:#{@race.id}:votes"
      @race.summary (err, actual) ->
        assert @store.lrange.calledWith expectedKey, 0, -1
        assert @store.llen.calledWith expectedKey
        assert.equal actual.id, @race.id
        assert.equal actual.total, 10
        assert.equal actual.avg, 2.5
        assert.equal actual.count, 4
