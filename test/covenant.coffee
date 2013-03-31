should = require 'should'
{Covenant} = require('../covenant')
{bestTick} = require('../bestTick')

# test scaffolding
p = p2 = p3 = returnPromise = callback = null
dummy = {dummy: 'dummy'}
dummy1 = {dummy: 'dummy1'}
dummy2 = {dummy2: 'dummy2'}
dummyReason = new Error 'dummyReason'

# status testing
testFulfilled = (p)-> p.state.should.have.ownProperty "value", "promise not fulfilled"
testRejected = (p)-> p.state.should.have.ownProperty "reason", "promise not rejected"
testPending = (p)->
  should.not.exist p.state?.value, "promise fulfilled, not pending"
  should.not.exist p.state?.reason, "promise rejected, not pending"

describe "Covenant", ->
  beforeEach ->
    p = new Covenant

  describe "state transitions", ->
    it "should default to a pending state", ->
      testPending(p)
    it "should be rejected after a call to reject() from the pending state", ->
      p.reject()
      testRejected(p)
    it "should be fulfilled after a call to fulfill() fron the pending state", ->
      p.fulfill()
      testFulfilled(p)
    it "should remain fulfilled, even if subsequently rejected", ->
      p.fulfill()
      p.reject()
      testFulfilled(p) 
    it "should remain rejected, even if subsequently fulfilled", ->
      p.reject()
      p.fulfill()
      testRejected(p)

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
    it ", p2=p.then(nonFunction, __) returns p2 fulfilled with value", (done)->
      p2 = p.then(undefined, undefined)
      bestTick ->
        p2.state.value.should.eql dummy
        done()
    describe ", p2=p.then(function, __)", ->
      it ", executes the function on the value", (done) ->
        p.then (
          ((value) -> value.should.eql dummy; done())),
          undefined
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.then( (->dummy2), undefined)
          bestTick ->
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.then( (->throw dummyReason), undefined )
          bestTick ->
            p2.state.reason.should.eql dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Covenant
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.then(callback, undefined)
            setTimeout (->
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.then(callback, undefined)
            setTimeout (->
              p2.state.reason.should.eql dummyReason
              done()), 20

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.then(__, nonFunction) returns p2 rejected with reason", (done)->
      p2 = p.then(undefined, undefined)
      bestTick ->
        p2.state.reason.should.eql dummy
        done()
    describe ", p2=p.then(__, function)", ->
      it ", executes the function on the reason", (done) ->
        p.then undefined, ((reason) -> reason.should.eql dummy; done())
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.then( undefined, (->dummy2))
          bestTick ->
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.then( undefined, (->throw dummyReason))
          bestTick ->
            p2.state.reason.should.eql dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Covenant
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.then(undefined, callback)
            setTimeout (->
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.then(undefined, callback)
            setTimeout (->
              p2.state.reason.should.eql dummyReason
              done()), 20

  describe "pending instance p", ->
    describe ", p2=p.then(value, value)", ->
      beforeEach -> p2 = p.then dummy2, dummy2
      it "returns a pending promise", ->
        type = typeof p2.then
        type.should.eql 'function'
      it ", after p.fulfill(value), p2 is fulfilled with value", (done)->
        p.fulfill(dummy)
        bestTick ->
          p2.state.value.should.eql dummy
          done()
      it ", after reject(reason), p2 is rejected with value", (done)->
        p.reject(dummyReason)
        bestTick ->
          p2.state.reason.should.eql dummyReason
          done()
      describe ", and then p3=p.then(onFulfil, onReject)", ->
        it "p2 should be fulfilled after p.fulfill", (done)->
          p3=p.then( )
          p.fulfill(dummy)
          bestTick ->
            testFulfilled(p2)
            done()
        it "p2 and p3 should be fulfilled in sequence", (done) ->
          p3=p.then(
            ((value)->
              testFulfilled(p2)
              value.should.eql dummy
              done()),
            ((reason)->throw new Error) )
          testPending(p2)
          p.fulfill(dummy)
        it "p2 and p3 should be rejected in sequence", (done) ->
          p3=p.then(
            ((value)->throw new Error),
            ((reason)->
              testRejected(p2)
              reason.should.eql dummyReason
              done()))
          testPending(p2)
          p.reject(dummyReason)

  describe "pending promise p, when p2=p.then(f,r), and f returns a promise", ->
    beforeEach ->
      returnPromise = new Covenant
      p2 = p.then((->returnPromise), (->returnPromise))
    describe ", p is fulfilled", ->
      beforeEach -> p.fulfill(dummy)
      it "p2 should be a pending promise", (done)->
        setTimeout (->
          testPending(p2)
          done()), 100
      describe ", after returnPromise.fulfill(value)", ->
        beforeEach -> returnPromise.fulfill(dummy2)
        it ", p2 should be fulfilled with the value", (done)->
          setTimeout (->
            p2.state.value.should.eql dummy2
            done()), 100
      describe ", after returnPromise.reject(reason)", ->
        beforeEach -> returnPromise.reject(dummyReason)
        it ", p2 should be rejected for the reason", (done)->
          bestTick ->
            p2.state.reason.should.eql dummyReason
            done()
    describe ", p is rejected", ->
      beforeEach -> p.reject(dummyReason)
      it "p2 should be a pending promise", (done)->
        setTimeout (->
          testPending(p2)
          done()), 100
      describe ", after returnPromise.fulfill(value)", ->
        beforeEach -> returnPromise.fulfill(dummy2)
        it ", p2 should be fulfilled with the value", (done)->
          setTimeout (->
            p2.state.value.should.eql dummy2
            done()), 100
      describe ", after returnPromise.reject(reason)", ->
        beforeEach -> returnPromise.reject(dummyReason)
        it ", p2 should be rejected for the reason", (done)->
          bestTick ->
            p2.state.reason.should.eql dummyReason
            done()
          
  describe "per spec, then must return before", ->
    describe "an onFulfill callback is executed", ->
      it "from a pending promise", (done) ->
        thenHasReturned = false
        p.then ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true
        p.fulfill(dummy)
      it "from a fulfilled promise", (done) ->
        p.fulfill(dummy)
        thenHasReturned = false
        p.then ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true
      it "from a rejected promise", (done) ->
        p.reject(dummyReason)
        thenHasReturned = false
        p.then undefined, ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true

  describe "p.fulfill", ->
    it "should be bound to p", ->
      p = new Covenant
      f = p.fulfill
      f(dummy)
      p.state.value.should.eql dummy

  describe "p.reject should be bound to p", ->
    it "should be bound to p", ->
      p = new Covenant
      f = p.reject
      f(dummyReason)
      p.state.reason.should.eql dummyReason

  describe "p.then should be bound to p", ->
    it "should be bound to p", (done)->
      p = new Covenant
      f = p.then
      callback = (value) ->
        value.should.eql dummy
        done()
      f(callback)
      p.fulfill(dummy)

  describe "Run covenant against the Promises/A+ Test Suite", ->
    @slow(500)
    require('promises-aplus-tests').mocha
      fulfilled: (value) -> p=new Covenant; p.fulfill(value); p
      rejected: (reason) -> p=new Covenant; p.reject(reason); p
      pending: ->
        p = new Covenant
        promise: p
        fulfill: p.fulfill
        reject: p.reject
