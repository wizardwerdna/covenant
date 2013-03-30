should = require 'should'
{Promise} = require('../index')

p = p1 = p2 = p3 = returnPromise = callback = null
dummy = {dummy: 'dummy'}
dummy1 = {dummy: 'dummy1'}
dummy2 = {dummy: 'dummy2'}
dummy3 = {dummy: 'dummy3'}
dummyReason = new Error 'dummyReason'
dummyReason2 = new Error 'dummyReason2'

describe "Promise", ->
  beforeEach -> p = new Promise

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

  describe "After p = Promise.when(v1, v2, v3), all values", ->
    beforeEach -> p = Promise.when dummy1, dummy2, dummy3
    it "should synchronously return an aggregate promise", ->
      'function'.should.eql typeof p?.then
    it "should synchronously return a fulfilled promise", ->
      p.state.status().should.eql 'fulfilled'
    it "should synchronously return a promise fulfilled with the values", ->
      p.state.value.should.eql [dummy1, dummy2, dummy3]
  describe "After p = Promise.when(v1, v2, p1), p1 a value-fulfilled promise", ->
    beforeEach ->
      p1 = Promise.fulfilled(dummy3)
      p = Promise.when dummy1, dummy2, p1
    it "should return a fulfilled promise with the appropriate value array", (done)->
      setTimeout (->
        p.state.status().should.eql 'fulfilled'
        p.state.value.should.eql [dummy1, dummy2, dummy3]
        done()), 20
  describe "After p = Promise.when(v1, v2, p1), p1 a value-rejected promise", ->
    beforeEach ->
      p1 = Promise.rejected(dummyReason)
      p = Promise.when dummy1, dummy2, p1
    it "should return a fulfilled promise with the appropriate value array", (done)->
      setTimeout (->
        p.state.status().should.eql 'rejected'
        p.state.reason.should.eql dummyReason
        done()), 20
  describe "After p = Promise.when(v1, p1, p2), p1 and p2 pending promises", ->
    beforeEach ->
      [p1, p2] = [new Promise, new Promise]
      p = Promise.when(dummy1, p1, p2)
    it "should be pending when not all promises have been fulfilled", ->
      p1.fulfill(dummy2)
      p.state.status().should.eql 'pending'
    it "should be fulfilled wth a value array after promises are fulfilled with values", (done) ->
      p1.fulfill(dummy2)
      p2.fulfill(dummy3)
      p.then (result) ->
        result.should.eql [dummy1, dummy2, dummy3]
        done()
    it "should be rejected with the reason after the first promise is rejected", (done) ->
      p1.reject(dummyReason)
      p2.fulfill(dummy1)
      p.then null, (reason) ->
        reason.should.eql dummyReason
        done()
    it "should remain pending after one of p1 is fulfilled with a pending promise", (done) ->
      p3 = new Promise
      p1.fulfill(p3)
      p2.fulfill(dummy3)
      setTimeout (->
        p.state.status().should.eql 'pending'
        done()), 20
    it "should be fulfilled after p1 is fulfilled with a pending promise, later fulfilled", (done) ->
      p3 = new Promise
      p1.fulfill(p3)
      p2.fulfill(dummy3)
      p3.fulfill(dummy2)
      setTimeout (->
        p.state.status().should.eql 'fulfilled'
        p.state.value.should.eql [dummy1, dummy2, dummy3]
        done()), 20
    it "should be rejected after p1 is fulfilled with a pending promise, later rejected", (done) ->
      p3 = new Promise
      p1.fulfill(p3)
      p2.fulfill(dummy3)
      p3.reject(dummyReason)
      setTimeout (->
        p.state.status().should.eql 'rejected'
        p.state.reason.should.eql dummyReason
        done()), 20

  describe "Promise.fromNode", ->
    describe "when passed a function f", ->
      it "should return a function", ->
        Promise.fromNode((cb)->).should.be.a 'function'
      it "if f is n-adic, should return an n-1-adic function that returns a promise", ->
        Promise.fromNode((cb)->)()?.then.should.be.a 'function'
        (Promise.fromNode((a,b,c,d)->)(1,2,3))?.then.should.be.a 'function'
      it "should be pending until f calls its callback", (done)->
        setTimeout (->
          Promise.fromNode((cb)->)().state.status().should.eql 'pending'
          done()), 20
      it "should fulfill with value if f's cb(false, value)", (done) ->
        setTimeout (->
          Promise.fromNode((cb)->cb(false, dummy1))().state.value.should.eql dummy1
          done()), 20
      it "should reject with err if f's cb(err, value) has truthy err", (done) ->
        setTimeout (->
          Promise.fromNode((cb)->cb(dummyReason, dummy1))().state.reason.should.eql dummyReason
          done()), 20

  describe "Promise.delay(ms)", ->
    it "should return a promise", ->
      Promise.delay(20)?.then.should.be.a 'function'
    it "should be pending until ms milliseconds have passed", (done)->
      p = Promise.delay(20)
      setTimeout (->
        p.state.status().should.eql 'pending'
        done()), 17
    it "should be fulfilled after ms milliseconds have passed", (done)->
      p = Promise.delay(20)
      setTimeout (->
        p.state.status().should.eql 'fulfilled'
        done()), 23

  describe "Promise.timeout(ms, p)", ->
    beforeEach ->
      p = new Promise
      p2 = Promise.timeout(20, p)
    it "should return a promise p2", ->
      p2?.then.should.be.a 'function'
    it "if p not resolved, p2 remains pending until ms milliseconds have passed", (done)->
      setTimeout (->
        p2.state.status().should.eql 'pending'
        done()), 17
    it "if p not resolved beforehand, p2 should be rejected after ms milliseconds have passed", (done)->
      p = Promise.delay(20)
      setTimeout (->
        p2.state.reason.should.eql new Error "timeout after 20 milliseconds"
        done()), 25
    it "if p fulfilled before ms milliseconds, it remains so resolved afterward", (done)->
      p.fulfill(dummy1)
      setTimeout (->
        p2.state.value.should.eql dummy1
        done()), 25
    it "if p rejected before ms milliseconds, it remains so resolved afterward", (done) ->
      p.reject(dummyReason)
      setTimeout (->
        p2.state.reason.should.eql dummyReason
        done()), 25

  describe "p.thenable()", ->
    beforeEach -> p2 = p.thenable()
    it "should have an identical then operation", ->
      p2.then.should.equal p.then
    it "should mirror convenience functions", ->
      p2.done.should.equal p.done
      p2.fail.should.equal p.fail
      p2.always.should.equal p.always
    it "should not have resolution functions", ->
      should.not.exist p2.fulfill
      should.not.exist p2.reject

  describe "p.resolver()", ->
    beforeEach -> p2 = p.resolver()
    it "should have identical resolution functions", ->
      p2.fulfill.should.equal p.fulfill
      p.reject.should.equal p.reject
    it "should not have then or convenience functionality", ->
      should.not.exist p2.then
