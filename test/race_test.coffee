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

  describe "#total", ->
    beforeEach ->
      @store =
        lrange: bond().return([1,2,3,1])
      @race = new Race @store

    it 'returns a sum of all votes', ->
      expectedKey = "races:#{@race.id}:votes"
      actual = @race.total()

      assert @store.lrange.calledWith expectedKey, 0, -1
      assert.equal actual, 7
