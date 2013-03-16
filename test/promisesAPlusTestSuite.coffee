should = require 'should'
Covenant = require('../covenant').Covenant

describe "Run covenant against the Promises/A+ Test Suite", ->
  @slow(500)
  require('promises-aplus-tests').mocha
    fulfilled: (value) -> (new Covenant).fulfill(value)
    rejected: (reason) -> (new Covenant).reject(reason)
    pending: ->
      promise: new Covenant
      fulfill: (value) -> @promise.fulfill(value)
      reject: (reason) -> @promise.reject(reason)
