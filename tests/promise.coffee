should = require 'should'
Promise = require('../promise2').Promise

p = null
describe "Promise", ->
  beforeEach -> p = new Promise
  describe "state transitions", ->
    it "should default to a pending state", ->
      p.status().should.eql 'pending'
    it "should be rejected after a call to reject() from the pending state", ->
      p.reject()
      p.status().should.eql 'rejected'
    it "should be fulfilled after a call to fulfill() fron the pending state", ->
      p.fulfill()
      p.status().should.eql 'fulfilled'
    it "should remain fulfilled, even if subsequently rejected", ->
      p.fulfill()
      p.reject()
      p.status().should.eql 'fulfilled'
    it "should remain rejected, even if subsequently fulfilled", ->
      p.reject()
      p.fulfill()
      p.status().should.eql 'rejected'
