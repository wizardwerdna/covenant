should = require 'should'
Covenant = require('../covenant').Covenant

describe "Run covenant against the Promises/A+ Test Suite", ->
  @slow(500)
  require('promises-aplus-tests').mocha
    fulfilled: (value) -> p=new Covenant; p.fulfill(value); p
    rejected: (reason) -> p=new Covenant; p.reject(reason); p
    pending: ->
      promise: new Covenant
      fulfill: (value) -> @promise.fulfill(value)
      reject: (reason) -> @promise.reject(reason)
