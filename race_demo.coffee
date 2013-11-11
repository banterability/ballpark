redis = require 'redis'
client = redis.createClient()

Race = require './lib/race'

r = new Race client

console.log r.id, r.key

r.vote 1
r.vote 5
r.vote 4
r.vote 1

r.summary (err, res) ->
  console.log "summary", res
