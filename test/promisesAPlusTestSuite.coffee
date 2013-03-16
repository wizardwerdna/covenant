should = require 'should'
Promise = require('../promise2').Promise

describe "Promises/A+ Test Suite", ->
  @slow(500)
  require('promises-aplus-tests').mocha
    fulfilled: (value) -> (new Promise).fulfill(value)
    rejected: (reason) -> (new Promise).reject(reason)
    pending: ->
      promise: new Promise
      fulfill: (value) -> @promise.fulfill(value)
      reject: (reason) -> @promise.reject(reason)
