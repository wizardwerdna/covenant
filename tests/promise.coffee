should = require 'should'
Promise = require('../promise2').Promise

p = p2 = returnPromise = callback = null
dummy = {dummy: 'dummy'}
dummy2 = {dummy2: 'dummy2'}
dummyReason = new Error 'dummyReason'

describe "Promise", ->
  beforeEach ->
    p = new Promise

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

  describe "state transition datum", ->
    it "should remember the given value after fulfill(value)", ->
      p.fulfill(dummy)
      p.state.value.should.eql dummy
      p.reject(undefined)
      p.state.value.should.eql dummy
    it "should remember the given reason after reject(reason)", ->
      p.reject(dummy)
      p.state.reason.should.eql dummy
      p.state.reason.should.eql dummy
      p.fulfill(undefined)
  
  describe "instance p, fulfilled with value", ->
    beforeEach -> p.fulfill(dummy)
    it ", p2=p.then(nonFunction, __) returns p2 fulfilled with value", ->
      p.then(undefined, undefined).status().should.eql 'fulfilled'
      p.then(undefined, undefined).state.value.should.eql dummy
    describe ", p2=p.then(function, __)", ->
      it ", executes the function on the value", (done) ->
        p.then (
          ((value) -> value.should.eql dummy; done())),
          undefined
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", ->
          p.then( (->dummy2), undefined).status().should.eql 'fulfilled'
          p.then( (->dummy2), undefined).state.value.should.eql dummy2
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", ->
          p.then( (->throw dummyReason), undefined ).status().should.eql 'rejected'
          p.then( (->throw dummyReason), undefined ).state.reason.should.eql dummyReason
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Promise
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", ->
            p.then(callback, undefined).status().should.eql 'fulfilled'
            p.then(callback, undefined).state.value.should.eql dummy2
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", ->
            p.then(callback, undefined).status().should.eql 'rejected'
            p.then(callback, undefined).state.reason.should.eql dummyReason

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.then(__, nonFunction) returns p2 rejected with reason", ->
      p.then(undefined, undefined).status().should.eql 'rejected'
      p.then(undefined, undefined).state.reason.should.eql dummy
    describe ", p2=p.then(__, function)", ->
      it ", executes the function on the reason", (done) ->
        p.then undefined, ((reason) -> reason.should.eql dummy; done())
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", ->
          p.then( undefined, (->dummy2)).status().should.eql 'fulfilled'
          p.then( undefined, (->dummy2)).state.value.should.eql dummy2
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", ->
          p.then( undefined, (->throw dummyReason)).status().should.eql 'rejected'
          p.then( undefined, (->throw dummyReason)).state.reason.should.eql dummyReason
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Promise
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", ->
            p.then(undefined, callback).status().should.eql 'fulfilled'
            p.then(undefined, callback).state.value.should.eql dummy2
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", ->
            p.then(undefined, callback).status().should.eql 'rejected'
            p.then(undefined, callback).state.reason.should.eql dummyReason

