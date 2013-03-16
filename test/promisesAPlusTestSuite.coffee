should = require 'should'
Oath = require('../oath').Oath

describe "Run oath against the Promises/A+ Test Suite", ->
  @slow(500)
  require('promises-aplus-tests').mocha
    fulfilled: (value) -> (new Oath).fulfill(value)
    rejected: (reason) -> (new Oath).reject(reason)
    pending: ->
      promise: new Oath
      fulfill: (value) -> @promise.fulfill(value)
      reject: (reason) -> @promise.reject(reason)
