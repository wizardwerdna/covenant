should = require 'should'
Promise = require('../promise').Promise

p = p1 = p2 = p3 = returnPromise = callback = null
dummy = {dummy: 'dummy'}
dummy1 = {dummy: 'dummy1'}
dummy2 = {dummy: 'dummy2'}
dummy3 = {dummy: 'dummy3'}
dummyReason = new Error 'dummyReason'
dummyReason2 = new Error 'dummyReason2'

describe "Promise", ->
  beforeEach ->
    p = new Promise

  describe "state transitions", ->
    it "should default to a pending state", ->
      p.state.status().should.eql 'pending'
    it "should be rejected after a call to reject() from the pending state", ->
      p.reject()
      p.state.status().should.eql 'rejected'
    it "should be fulfilled after a call to fulfill() fron the pending state", ->
      p.fulfill()
      p.state.status().should.eql 'fulfilled'
    it "should remain fulfilled, even if subsequently rejected", ->
      p.fulfill()
      p.reject()
      p.state.status().should.eql 'fulfilled'
    it "should remain rejected, even if subsequently fulfilled", ->
      p.reject()
      p.fulfill()
      p.state.status().should.eql 'rejected'

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
    it ", p2=p.done(nonFunction) returns p2 fulfilled with value", (done)->
      p2 = p.done(undefined)
      setImmediate ->
        p2.state.status().should.eql 'fulfilled'
        p2.state.value.should.eql dummy
        done()
    describe ", p2=p.done(function)", ->
      it ", executes the function on the value", (done) ->
        p.done (value) -> value.should.eql dummy; done()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.done ->dummy2
          setImmediate ->
            p2.state.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.done ->throw dummyReason
          setImmediate ->
            p2.state.status().should.eql 'rejected'
            p2.state.reason.should.eql dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Promise
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.done callback
            setTimeout (->
              p2.state.status().should.eql 'fulfilled'
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.done callback
            setTimeout (->
              p2.state.status().should.eql 'rejected'
              p2.state.reason.should.eql dummyReason
              done()), 20

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.fail(nonFunction) returns p2 rejected with reason", (done)->
      p2 = p.fail(undefined)
      setImmediate ->
        p2.state.status().should.eql 'rejected'
        p2.state.reason.should.eql dummy
        done()
    describe ", p2=p.fail(function)", ->
      it ", executes the function on the reason", (done) ->
        p.fail (reason) -> reason.should.eql dummy; done()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.fail -> dummy2
          setImmediate ->
            p2.state.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.fail ->throw dummyReason
          setImmediate ->
            p2.state.status().should.eql 'rejected'
            p2.state.reason.should.eql dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Promise
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.fail callback
            setTimeout (->
              p2.state.status().should.eql 'fulfilled'
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.fail callback
            setTimeout (->
              p2.state.status().should.eql 'rejected'
              p2.state.reason.should.eql dummyReason
              done()), 20
  
  describe "instance p, fulfilled with value", ->
    beforeEach -> p.fulfill(dummy)
    it ", p2=p.always(nonFunction) returns p2 fulfilled with value", (always)->
      p2 = p.always(undefined)
      setImmediate ->
        p2.state.status().should.eql 'fulfilled'
        p2.state.value.should.eql dummy
        always()
    describe ", p2=p.always(function)", ->
      it ", executes the function on the value", (always) ->
        p.always (value) -> value.should.eql dummy; always()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (always)->
          p2 = p.always ->dummy2
          setImmediate ->
            p2.state.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            always()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (always)->
          p2 = p.always ->throw dummyReason
          setImmediate ->
            p2.state.status().should.eql 'rejected'
            p2.state.reason.should.eql dummyReason
            always()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Promise
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (always)->
            p2 = p.always callback
            setTimeout (->
              p2.state.status().should.eql 'fulfilled'
              p2.state.value.should.eql dummy2
              always()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (always)->
            p2 = p.always callback
            setTimeout (->
              p2.state.status().should.eql 'rejected'
              p2.state.reason.should.eql dummyReason
              always()), 20

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.always(nonFunction) returns p2 rejected with reason", (always)->
      p2 = p.always(undefined)
      setImmediate ->
        p2.state.status().should.eql 'rejected'
        p2.state.reason.should.eql dummy
        always()
    describe ", p2=p.always(function)", ->
      it ", executes the function on the reason", (always) ->
        p.always (reason) -> reason.should.eql dummy; always()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (always)->
          p2 = p.always -> dummy2
          setImmediate ->
            p2.state.status().should.eql 'fulfilled'
            p2.state.value.should.eql dummy2
            always()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (always)->
          p2 = p.always ->throw dummyReason
          setImmediate ->
            p2.state.status().should.eql 'rejected'
            p2.state.reason.should.eql dummyReason
            always()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Promise
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (always)->
            p2 = p.always callback
            setTimeout (->
              p2.state.status().should.eql 'fulfilled'
              p2.state.value.should.eql dummy2
              always()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (always)->
            p2 = p.always callback
            setTimeout (->
              p2.state.status().should.eql 'rejected'
              p2.state.reason.should.eql dummyReason
              always()), 20
  
  describe "per spec, done, fail and always must return before", ->
    describe "an onFulfill callback is executed", ->
      it "p.done() from a pending promise", (done) ->
        thenHasReturned = false
        p.done ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true
        p.fulfill(dummy)
      it "p.fail() from a pending promise later rejected", (done) ->
        thenHasReturned = false
        p.fail ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true
        p.reject(dummyReason)
      it "p.always() from a pending promise", (done) ->
        thenHasReturned = false
        p.always ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true
        p.fulfill(dummy)
      it "p.always() from a fulfilled promise", (done) ->
        p.fulfill(dummy)
        thenHasReturned = false
        p.always ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true
      it "p.always() from a rejected promise", (done) ->
        p.reject(dummyReason)
        thenHasReturned = false
        p.always ()->
          thenHasReturned.should.be.true
          done()
        thenHasReturned = true

  describe "After p = Promise.when(p1, p2, p3)", ->
    beforeEach ->
      [p1, p2, p3] = [new Promise, new Promise, new Promise]
      p = Promise.when(p1, p2, p3)
    it "should be pending when not all promises have been fulfilled", ->
      p1.fulfill(dummy)
      p2.fulfill(dummy)
      p.state.status.should == 'pending'
    it "should be fulfilled wth an array of results after fullfilling all promises", (done) ->
      p3.fulfill(dummy3)
      p1.fulfill(dummy1)
      p2.fulfill(dummy2)
      p.then (result) ->
        result.should.eql [dummy1, dummy2, dummy3]
        done()
    it "should be rejected with the reason given by the first response rejected", (done) ->
      p3.fulfill(dummy3)
      p2.reject(dummy2)
      p1.reject(dummy1)
      p.then null, (reason) ->
        reason.should.eql dummy2
        done()
