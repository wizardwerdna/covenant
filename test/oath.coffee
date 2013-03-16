should = require 'should'
Oath = require('../oath').Oath

p = p2 = p3 = returnPromise = callback = null
dummy = {dummy: 'dummy'}
dummy2 = {dummy2: 'dummy2'}
dummyReason = new Error 'dummyReason'

describe "Promise", ->
  beforeEach ->
    p = new Oath

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
    it ", p2=p.then(nonFunction, __) returns p2 fulfilled with value", (done)->
      p2 = p.then(undefined, undefined)
      process.nextTick ->
        p2.status().should.eql 'fulfilled'
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
          process.nextTick ->
            p2.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.then( (->throw dummyReason), undefined )
          process.nextTick ->
            p2.status().should.eql 'rejected'
            p2.state.reason.should.eql dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Oath
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.then(callback, undefined)
            setTimeout (->
              p2.status().should.eql 'fulfilled'
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.then(callback, undefined)
            setTimeout (->
              p2.status().should.eql 'rejected'
              p2.state.reason.should.eql dummyReason
              done()), 20

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.then(__, nonFunction) returns p2 rejected with reason", (done)->
      p2 = p.then(undefined, undefined)
      process.nextTick ->
        p2.status().should.eql 'rejected'
        p2.state.reason.should.eql dummy
        done()
    describe ", p2=p.then(__, function)", ->
      it ", executes the function on the reason", (done) ->
        p.then undefined, ((reason) -> reason.should.eql dummy; done())
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.then( undefined, (->dummy2))
          process.nextTick ->
            p2.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.then( undefined, (->throw dummyReason))
          process.nextTick ->
            p2.status().should.eql 'rejected'
            p2.state.reason.should.eql dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Oath
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.then(undefined, callback)
            setTimeout (->
              p2.status().should.eql 'fulfilled'
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.then(undefined, callback)
            setTimeout (->
              p2.status().should.eql 'rejected'
              p2.state.reason.should.eql dummyReason
              done()), 20

  describe "pending instance p", ->
    describe ", p2=p.then(value, value)", ->
      beforeEach -> p2 = p.then dummy2, dummy2
      it "returns a pending promise", ->
        type = typeof p2.then
        type.should.eql 'function'
        p2.status().should.eql 'pending'
      it ", after p.fulfill(value), p2 is fulfilled with value", (done)->
        p.fulfill(dummy)
        process.nextTick ->
          p2.status().should.eql 'fulfilled'
          p2.state.value.should.eql dummy
          done()
      it ", after reject(reason), p2 is rejected with value", (done)->
        p.reject(dummyReason)
        process.nextTick ->
          p2.status().should.eql 'rejected'
          p2.state.reason.should.eql dummyReason
          done()
      describe ", and then p3=p.then(onFulfil, onReject)", ->
        it "p2 should be fulfilled after p.fulfill", (done)->
          p3=p.then( )
          p.fulfill(dummy)
          process.nextTick ->
            p2.status().should.eql 'fulfilled'
            done()
        it "p2 and p3 should be fulfilled in sequence", (done) ->
          p3=p.then(
            ((value)->
              p2.status().should.eql 'fulfilled'
              value.should.eql dummy
              done()),
            ((reason)->throw new Error) )
          p2.status().should.eql 'pending'
          p.fulfill(dummy)
        it "p2 and p3 should be rejected in sequence", (done) ->
          p3=p.then(
            ((value)->throw new Error),
            ((reason)->
              p2.status().should.eql 'rejected'
              reason.should.eql dummyReason
              done()))
          p2.status().should.eql 'pending'
          p.reject(dummyReason)

  describe "pending promise p, when p2=p.then(f,r), and f returns a promise", ->
    beforeEach ->
      returnPromise = new Oath
      p2 = p.then((->returnPromise), (->returnPromise))
    describe ", p is fulfilled", ->
      beforeEach -> p.fulfill(dummy)
      it "p2 should be a pending promise", (done)->
        setTimeout (->
          p2.status().should.eql 'pending'
          done()), 100
      describe ", after returnPromise.fulfill(value)", ->
        beforeEach -> returnPromise.fulfill(dummy2)
        it ", p2 should be fulfilled with the value", (done)->
          setTimeout (->
            p2.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            done()), 100
      describe ", after returnPromise.reject(reason)", ->
        beforeEach -> returnPromise.reject(dummyReason)
        it ", p2 should be rejected for the reason", (done)->
          process.nextTick ->
            p2.status().should.eql 'rejected'
            p2.state.reason.should.eql dummyReason
            done()
    describe ", p is rejected", ->
      beforeEach -> p.reject(dummyReason)
      it "p2 should be a pending promise", (done)->
        setTimeout (->
          p2.status().should.eql 'pending'
          done()), 100
      describe ", after returnPromise.fulfill(value)", ->
        beforeEach -> returnPromise.fulfill(dummy2)
        it ", p2 should be fulfilled with the value", (done)->
          setTimeout (->
            p2.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            done()), 100
      describe ", after returnPromise.reject(reason)", ->
        beforeEach -> returnPromise.reject(dummyReason)
        it ", p2 should be rejected for the reason", (done)->
          process.nextTick ->
            p2.status().should.eql 'rejected'
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

