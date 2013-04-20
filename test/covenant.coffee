should = window?.should ? require('chai').Should()
chai = window?.chai ? require('chai')

sinon = window?.sinon ? require('sinon')
unless window?
  sinonChai = window?.sinonChai ? require('sinon-chai')
  chai.use sinonChai

{covenantTestHelper} = window ? (require './helpers/covenantTestHelper')
chai.use covenantTestHelper

{Core, Covenant, enqueue} = window ? require '../covenant'

# test scaffolding
p = p2 = p3 = returnPromise = callback = null
dummy = {dummy: 'dummy'}
dummy1 = {dummy: 'dummy1'}
dummy2 = {dummy2: 'dummy2'}
dummyReason = new Error 'dummyReason'

describe "Core", ->
  beforeEach ->
    p = new Core

  describe "creation", ->
    it "should throw a TypeError unless its parameter is a function", ->
      (->new Core 23).should.throw TypeError
    it "should call the resolver synchronously brefore returning", (done)->
      returned = false
      new Core ->
        returned.should.be.false
        done()
      returned = true
    it "should pass the resolver, rejector and the promise as parameters",
      resolver = sinon.spy()
      p = new Core resolver
      resolver.should.have.been.calledWith(p.resolve, p.reject, p)
    it "should call the resolver in the context of the promise",
      resolver = sinon.spy()
      p = new Core resolver
      resolver.calledOn(p).should.be.true
    it "should reject with an error if the resolver throws", ->
      p = new Core (-> throw dummyReason)
      p.should.be.rejected.withReason(dummyReason)

  describe "state transitions", ->
    it "should be a Covenant", ->
      p.should.be.a.covenant
    it "should default to a pending state", ->
      p.should.be.pending
    it "should be rejected after a call to reject() from the pending state", ->
      p.reject(dummyReason)
      p.should.be.rejected.withReason(dummyReason)
    it "should be fulfilled after a call to fulfill() fron the pending state", ->
      p.fulfill(dummy)
      p.should.be.fulfilled.withValue(dummy)
    it "should remain fulfilled, even if subsequently rejected", ->
      p.fulfill(dummy)
      p.reject(dummyReason)
      p.should.be.fulfilled
    it "should remain rejected, even if subsequently fulfilled", ->
      p.reject(dummyReason)
      p.fulfill(dummy)
      p.should.be.rejected.withReason(dummyReason)

  describe "instance p, fulfilled with value", ->
    beforeEach -> p.fulfill(dummy)
    it ", p2=p.then(nonFunction, __) returns p2 fulfilled with value", (done)->
      p2 = p.then(undefined, undefined)
      enqueue ->
        p2.should.be.fulfilled.withValue dummy
        done()
    describe ", p2=p.then(function, __)", ->
      it ", executes the function on the value", (done) ->
        p.then (
          ((value) -> value.should.eql dummy; done())),
          undefined
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.then( (->dummy2), undefined)
          enqueue ->
            p2.should.be.fulfilled.withValue dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.then( (->throw dummyReason), undefined )
          enqueue ->
            p2.should.be.rejected.withReason dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Core
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.then(callback, undefined)
            setTimeout (->
              p2.should.be.fulfilled.withValue dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.then(callback, undefined)
            setTimeout (->
              p2.should.be.rejected.withReason dummyReason
              done()), 20

  describe "instance p, rejected with reason", ->
    beforeEach -> p.reject(dummy)
    it ", p2=p.then(__, nonFunction) returns p2 rejected with reason", (done)->
      p2 = p.then(undefined, undefined)
      enqueue ->
        p2.should.be.rejected.withReason dummy
        done()
    describe ", p2=p.then(__, function)", ->
      it ", executes the function on the reason", (done) ->
        p.then undefined, ((reason) -> reason.should.eql dummy; done())
      describe ", and function returns a non-promise value", ->
        it "p2 is fulfilled with the returned value", (done)->
          p2 = p.then( undefined, (->dummy2))
          enqueue ->
            p2.should.be.fulfilled.withValue dummy2
            done()
      describe ", and function throws an exception", ->
        it "p2 is rejected with the exception as its reason", (done)->
          p2 = p.then( undefined, (->throw dummyReason))
          enqueue ->
            p2.should.be.rejected.withReason dummyReason
            done()
      describe ", and function returns a promise", ->
        beforeEach ->
          returnPromise = new Core
          callback = -> returnPromise
        describe "fulfilled with a value", ->
          beforeEach -> returnPromise.fulfill dummy2
          it "p2 should be fulfilled with the returnPromise's value", (done)->
            p2 = p.then(undefined, callback)
            setTimeout (->
              p2.should.be.fulfilled.withValue dummy2
              done()), 20
        describe "rejected with a reason", ->
          beforeEach -> returnPromise.reject dummyReason
          it "p2 should be rejected with the returnPromise's reason", (done)->
            p2 = p.then(undefined, callback)
            setTimeout (->
              p2.should.be.rejected.withReason dummyReason
              done()), 20

  describe "pending instance p", ->
    describe ", p2=p.then(value, value)", ->
      beforeEach -> p2 = p.then dummy2, dummy2
      it "returns a pending promise", ->
        type = typeof p2.then
        type.should.eql 'function'
      it ", after p.fulfill(value), p2 is fulfilled with value", (done)->
        p.fulfill(dummy)
        enqueue ->
          p2.should.be.fulfilled.withValue dummy
          done()
      it ", after reject(reason), p2 is rejected with value", (done)->
        p.reject(dummyReason)
        enqueue ->
          p2.should.be.rejected.withReason dummyReason
          done()
      describe ", and then p3=p.then(onFulfil, onReject)", ->
        it "p2 should be fulfilled after p.fulfill", (done)->
          p3=p.then( )
          p.fulfill(dummy)
          enqueue ->
            p2.should.be.fulfilld
            done()
        it "p2 and p3 should be fulfilled in sequence", (done) ->
          p3=p.then(
            ((value)->
              p2.should.be.fulfillled
              value.should.eql dummy
              done()),
            ((reason)->throw new Error) )
          p2.should.be.pending
          p.fulfill(dummy)
        it "p2 and p3 should be rejected in sequence", (done) ->
          p3=p.then(
            ((value)->throw new Error),
            ((reason)->
              p2.should.be.rejected
              reason.should.eql dummyReason
              done()))
          p2.should.be.pending
          p.reject(dummyReason)

  describe "pending promise p, when p2=p.then(f,r), and f returns a promise", ->
    beforeEach ->
      returnPromise = new Core
      p2 = p.then((->returnPromise), (->returnPromise))
    describe ", p is fulfilled", ->
      beforeEach -> p.fulfill(dummy)
      it "p2 should be a pending promise", (done)->
        setTimeout (->
          p2.should.be.pending
          done()), 100
      describe ", after returnPromise.fulfill(value)", ->
        beforeEach -> returnPromise.fulfill(dummy2)
        it ", p2 should be fulfilled with the value", (done)->
          setTimeout (->
            p2.should.be.fulfilled.withValue dummy2
            done()), 100
      describe ", after returnPromise.reject(reason)", ->
        beforeEach -> returnPromise.reject(dummyReason)
        it ", p2 should be rejected for the reason", (done)->
          setTimeout (->
            p2.should.be.rejected.withReason dummyReason
            done()), 20
    describe ", p is rejected", ->
      beforeEach -> p.reject(dummyReason)
      it "p2 should be a pending promise", (done)->
        setTimeout (->
          p2.should.be.pending
          done()), 100
      describe ", after returnPromise.fulfill(value)", ->
        beforeEach -> returnPromise.fulfill(dummy2)
        it ", p2 should be fulfilled with the value", (done)->
          setTimeout (->
            p2.should.be.fulfilled.withValue dummy2
            done()), 100
      describe ", after returnPromise.reject(reason)", ->
        beforeEach -> returnPromise.reject(dummyReason)
        it ", p2 should be rejected for the reason", (done)->
          setTimeout (->
            p2.should.be.rejected.withReason dummyReason
            done()), 20
          
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
      p = new Core
      f = p.fulfill
      f(dummy)
      p.should.be.fulfilled.withValue dummy

  describe "p.reject should be bound to p", ->
    it "should be bound to p", ->
      p = new Core
      f = p.reject
      f(dummyReason)
      p.should.be.rejected.withReason dummyReason

  describe "p.then should be bound to p", ->
    it "should be bound to p", (done)->
      p = new Core
      f = p.then
      callback = (value) ->
        value.should.eql dummy
        done()
      f(callback)
      p.fulfill(dummy)

  describe "p.promise", ->
    it "should be a Covenant", ->
      p.promise.should.be.a.covenant
    it "should be a thenable", ->
      p.promise.then.should.be.a 'function'
    it "should not provide resolution functions", ->
      should.not.exist p.promise.fulfill
      should.not.exist p.promise.reject
      should.not.exist p.promise.resolve
      Object.keys(p.promise).length.should.eql 1
    it "should be directly linked to the state of p after p fulfilled", (done)->
      p.fulfill(dummy)
      p.promise.then (value)->
        value.should.eql dummy
        done()
    it "should be directly linked to the state of p after p rejected", (done)->
      p.reject(dummy)
      p.should.be.rejected.withReason(dummy)
      p.promise.then undefined, (reason)->
        reason.should.eql dummy
        done()
    it "should be directly linked to the state of pending p, subsequently fulfilled", (done)->
      p.promise.then (value)->
        value.should.eql dummy
        done()
      p.fulfill(dummy)
    it "should be directly linked to the state of pending p, subsequently rejected", (done)->
      p.promise.then undefined, (reason)->
        reason.should.eql dummy
        done()
      p.reject(dummy)
    it "should have the identical .then function", ->
      p.promise.then.should.equal p.then
  
  describe "torture test using reduce (exposed a recursive nextTick)", ->
    it "should add the first numberOfIterations integers", (done)->
      numberOfIterations = 10000
      (initialPromise = (new Core)).fulfill(0)
      p = [1..numberOfIterations].reduce ((promise, nextVal)->
        promise.then (currentVal) ->
          d = new Core
          d.fulfill(currentVal + nextVal)
          d
      ), initialPromise
      setTimeout (->
        p.then (value)->
          value.should.eql (iter*(iter+1))/2
        done()), 20

  describe "Run covenant against the Promises/A+ Test Suite", ->
    @slow(500)
    @timeout(250)
    require?('promises-aplus-tests').mocha
      fulfilled: (value) -> p=new Core; p.resolve(value); p
      rejected: (reason) -> p=new Core; p.reject(reason); p
      pending: ->
        p = new Core
        promise: p
        fulfill: p.resolve
        reject: p.reject
