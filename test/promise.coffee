snhould = window?.should ? require('chai').Should()
chai = window?.chai ? require('chai')

sinon = window?.sinon ? require('sinon')
unless window?
  sinonChai = window?.sinonChai ? require('sinon-chai')
  chai.use sinonChai

{covenantTestHelper} = window ? (require './helpers/covenantTestHelper')
chai.use covenantTestHelper
should = window?.should ? require('chai').Should()

{Promise} = window ? require '../promise'
{enqueue} = window ? require '../covenant'

# test scaffold
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
    it "should sheboing correctly", ->
      Promise.fulfilled([1,2,3]).should.be.fulfilled.withValue([1,2,3])
    it "should default to a pending state", ->
      p.should.be.pending
    it "should be rejected after a call to reject() from the pending state", ->
      p.reject(dummyReason)
      p.should.be.rejected
    it "should be fulfilled after a call to fulfill() fron the pending state", ->
      p.fulfill(dummy)
      p.should.be.fulfilled
    it "should remain fulfilled, even if subsequently rejected", ->
      p.fulfill(dummy)
      p.reject(dummyReason)
      p.should.be.fulfilled
    it "should remain rejected, even if subsequently fulfilled", ->
      p.reject(dummyReason)
      p.fulfill(dummy)
      p.should.be.rejected

  describe "state transition datum", ->
    it "should remember the given value after fulfill(value)", ->
      p.fulfill(dummy)
      p.should.be.fulfilled.withValue dummy
      p.reject(dummyReason)
      p.should.be.fulfilled.withValue dummy
    it "should remember the given reason after reject(reason)", ->
      p.reject(dummy)
      p.should.be.rejected.withReason dummy
      p.should.be.rejected.withReason dummy
      p.fulfill(undefined)
  
  describe "instance p, fulfilled with value", ->
    beforeEach -> p.fulfill(dummy)
    it ", p2=p.done(nonFunction) returns p2 fulfilled with value", (done)->
      p2 = p.done(undefined)
      enqueue ->
        p2.state.value.should.eql dummy
        done()
    describe ", p2=p.done(function)", ->
      it ", executes the function on the value", (done) ->
        p.done (value) -> value.should.eql dummy; done()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.done ->dummy2
          enqueue ->
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.done ->throw dummyReason
          enqueue ->
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
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.done callback
            setTimeout (->
              p2.state.reason.should.eql dummyReason
              done()), 50

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.fail(nonFunction) returns p2 rejected with reason", (done)->
      p2 = p.fail(undefined)
      enqueue ->
        p2.state.reason.should.eql dummy
        done()
    describe ", p2=p.fail(function)", ->
      it ", executes the function on the reason", (done) ->
        p.fail (reason) -> reason.should.eql dummy; done()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.fail -> dummy2
          enqueue ->
            p2.state.value.should.eql dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.fail ->throw dummyReason
          enqueue ->
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
              p2.state.value.should.eql dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.fail callback
            setTimeout (->
              p2.state.reason.should.eql dummyReason
              done()), 20
  
  describe "instance p, fulfilled with value", ->
    beforeEach -> p.fulfill(dummy)
    it ", p2=p.always(nonFunction) returns p2 fulfilled with value", (always)->
      p2 = p.always(undefined)
      enqueue ->
        p2.state.value.should.eql dummy
        always()
    describe ", p2=p.always(function)", ->
      it ", executes the function on the value", (always) ->
        p.always (value) -> value.should.eql dummy; always()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (always)->
          p2 = p.always ->dummy2
          enqueue ->
            p2.state.value.should.eql dummy2
            always()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (always)->
          p2 = p.always ->throw dummyReason
          enqueue ->
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
              p2.state.value.should.eql dummy2
              always()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (always)->
            p2 = p.always callback
            setTimeout (->
              p2.state.reason.should.eql dummyReason
              always()), 20

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.always(nonFunction) returns p2 rejected with reason", (always)->
      p2 = p.always(undefined)
      enqueue ->
        p2.state.reason.should.eql dummy
        always()
    describe ", p2=p.always(function)", ->
      it ", executes the function on the reason", (always) ->
        p.always (reason) -> reason.should.eql dummy; always()
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (always)->
          p2 = p.always -> dummy2
          enqueue ->
            p2.state.value.should.eql dummy2
            always()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (always)->
          p2 = p.always ->throw dummyReason
          enqueue ->
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
              p2.state.value.should.eql dummy2
              always()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (always)->
            p2 = p.always callback
            setTimeout (->
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

  describe "map", ->
    describe "with integers and square function", ->
      beforeEach -> p = Promise.map [1,2,3], ((x)->x*x)
      it "should be a promise",->
        p.should.be.a.covenant
      it "should be fulfilled with proper values",(done)->
        p.then (value)->
          value.should.eql [1,4,9]
          done()
    describe "with integers and failing function", ->
      beforeEach -> p = Promise.map [1,2,3], (x)->
        switch x
          when 1 then 1
          when 2 then throw "dummyReason"
          when 3 then throw "dummyReason2"
      it "should be a promise",->
        p.should.be.a.covenant
      it "should be rejected with the first thrown value",(done)->
        p.then undefined, (reason)->
          reason.should.eql "dummyReason"
          done()
    describe "with integer-fulfilled promises", ->
      beforeEach -> p = Promise.map [Promise.of(1), Promise.of(2), Promise.of(3)], ((x)->x*x)
      it "should be fulfilled with proper values",(done)->
        p.then (value)->
          value.should.eql [1,4,9]
          done()
    describe "with an integer, an integer-fulfilled promise and a pending promise", ->
      beforeEach ->
        p3 = new Promise
        p = Promise.map [1, Promise.of(2), p3], ((x)->x*x)
      it "should remain pending until the pending promise fulfills", (done)->
        p.should.be.pending
        setTimeout (->
          p.should.be.pending
          p3.fulfill(3)
          p.then ->
            p.should.be.fulfilled
            done()), 20
      it "should compute the result after fulfillment", (done)->
        p3.fulfill(3)
        p.then (value) ->
          value.should.eql [1,4,9]
          done()
      it "should remain pending until the pending promise rejects", (done)->
        p.should.be.pending
        setTimeout (->
          p.should.be.pending
          p3.reject(dummyReason)
          p.then undefined, ->
            p.should.be.rejected
            done()), 20
      it "should be rejected with the failing reason", (done)->
        p3.reject(dummyReason)
        p.then undefined, (reason) ->
          reason.should.eql dummyReason
          done()
    describe "with three pending promises", ->
      beforeEach -> p=Promise.map [(p1=new Promise), (p2=new Promise), (p3=new Promise)], ((x)->x*x)
      it "should fulfill with the correct value regardless of order", (done)->
        p3.fulfill(3)
        p1.fulfill(1)
        p2.fulfill(2)
        p.then (value)->
          value.should.eql [1,4,9]
          done()
      it "should reject with the first rejected promise", (done)->
        p3.fulfill(3)
        p1.reject('dummyReason')
        p2.reject('dummyReason2')
        p.then undefined, (reason)->
          reason.should.eql 'dummyReason'
          done()
    
  describe "reduce", ->
    describe "with empty array", ->
      it "must reject unless an initial value is provided", (done)->
        Promise.reduce([], ->).then undefined, (reason)->
          reason.message.should.eql "resolve on empty array without an initial value"
          done()
      it "must resolve the iniial value if provided", (done)->
        Promise.reduce([], (->), 1).then (value)->
          value.should.eql 1
          done()
    describe "with singleton array", ->
      it "must resolve the singleton value without an initial value", (done)->
        Promise.reduce([1], (->)).then (value)->
          value.should.eql 1
          done()
      it "should apply the function to the singleton and initial value, when given", (done)->
        Promise.reduce([2], ((x,y)->x+y), 1).then ((value)->
          value.should.eql 3
          done())
    describe "with three values", ->
      it "must resolve correctly with values", (done)->
        Promise.reduce([1,2,3], ((x,y)->x+y)).then (value)->
          value.should.eql 6
          done()
    describe "with a value, a resolved promise and a pending promise", ->
      beforeEach ->
        p3 = new Promise
        p = Promise.reduce([1,(Promise.of 2),p3], ((x,y)->x+y))
      it "should remain pending when p3 remains unresolved", (done)->
        setTimeout (->
          p.should.be.pending
          done()), 20
      it "should be fulfilled with the correct value when p3 is resolved", (done)->
        p3.resolve(3)
        p.then (value)->
          value.should.eql 6
          done()
    describe "with three promises", ->
      beforeEach ->
        @array = [p1, p2, p3] = [new Promise, new Promise, new Promise]
        p = Promise.reduce @array, ((x,y)->x+y)
      it "should calculate when fulfilled in order", (done)->
        p1.fulfill 1
        p2.fulfill 2
        p3.fulfill 3
        p.then (value) ->
          value.should.eql 6
          done()
      it "should calculate when fulfilled in reverse order", (done)->
        p3.fulfill 3
        p2.fulfill 2
        p1.fulfill 1
        p.then (value) ->
          value.should.eql 6
          done()
      it "should calculate when fulfilled in arbitrary order", (done)->
        p2.fulfill 2
        p1.fulfill 1
        p3.fulfill 3
        p.then (value) ->
          value.should.eql 6
          done()


  describe "Promise.fromNode", ->
    describe "when passed a function f", ->
      it "should return a function", ->
        Promise.fromNode((cb)->).should.be.a 'function'
      it "if f is n-adic, should return an n-1-adic function that returns a promise", ->
        Promise.fromNode((cb)->)()?.then.should.be.a 'function'
        (Promise.fromNode((a,b,c,d)->)(1,2,3))?.then.should.be.a 'function'
      it "should be pending until f calls its callback", (done)->
        setTimeout (->
          Promise.fromNode((cb)->)().should.be.pending
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
        p.should.be.pending
        done()), 17 
    it "should be fulfilled after ms milliseconds have passed", (done)->
      p = Promise.delay(20)
      setTimeout (->
        p.should.be.fulfilled
        done()), 23

  describe "Promise.timeout(ms, p)", ->
    beforeEach ->
      p = new Promise
    it "should return a promise p2", ->
      p2?.then.should.be.a 'function'
    it "if p not resolved, p2 remains pending before ms milliseconds", (done)->
      p2 = Promise.timeout(20, p)
      setTimeout (->
        p2.should.be.pending
        done()), 10
    it "if p not resolved in time, p2 should be rejected after ms milliseconds", (done)->
      p2 = Promise.timeout(20, p)
      setTimeout (->
        p2.state.reason.toString().should.eql (
          new Error "timeout after 20 milliseconds").toString()
        done()), 30
    it "if p fulfilled before ms milliseconds, it remains so resolved afterward", (done)->
      p2 = Promise.timeout(20, p)
      p.fulfill(dummy1)
      setTimeout (->
        p2.state.value.should.eql dummy1
        done()), 25
    it "if p rejected before ms milliseconds, it remains so rejected afterward", (done) ->
      p2 = Promise.timeout(20, p)
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
