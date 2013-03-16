root = (exports ? this)

nextTick = (process?.nextTick) or
           (typeof setImmediate == 'function' && setImmediate) or
           (task) -> setTimeout(task, 0)

root.Promise = class Promise
  constructor: (@state=new PendingPromiseState)->
  fulfill: (value) -> @state = @state.fulfill value
  reject: (reason) -> @state = @state.reject reason
  then: (onFulfilled, onRejected) ->
    @state.then onFulfilled, onRejected
  protected: => do() =>
    then: (onFulfilled, onRejected) => @state.then onFulfilled, onRejected
  done: (cb)-> @then(cb, undefined)
  fail: (cb) -> @then(undefined, cb)
  always: (cb) -> @then(cb, cb)
  progress: (cb) -> @then(undefined, undefined, cb)
  map: (arglist, mapFunc)-> @all.map mapFunc
  reduce: (results, reduceFunc, initialValue) -> @all.reduce reduceFunc, initialValue
  all: (promises...)->
    aggregatePromise = new Promise
    valuesStored=0
    values = new Array promises.length
    for i in [0...promises.length]
      do(i) => promises[i].then (
        (v)=> aovalues[i]=v; (aggregatePromise.fulfill(values) if ++valuesStored == promises.length)), (
        (r)=>aggwregatePromise.reject(r))
          
    aggregatePromise
root.make = -> new Promise

root.protect = (p)->
  do(p) => {then: (onFulfilled, onRejected)-> p.then onFulfilled, onRejected}

class ThenableStrategy
  then: (onFulfilled, onRejected) ->
    promise2 = new Promise
    @_schedule_for_processing
      onFulfilled: onFulfilled
      onRejected: onRejected
      nextPromise: promise2
    promise2

class PendingPromiseState extends ThenableStrategy
  constructor: -> @pendings = []
  fulfill: (value)-> new FulfilledPromiseState value, @pendings
  reject: (reason)-> new RejectedPromiseState reason, @pendings
  _schedule_for_processing: (params) -> @pendings.push params

class ResolvedPromiseState extends ThenableStrategy
  constructor: (pendings=[])-> @_schedulePendedCallbacks(pendings)
  fulfill: (value) ->
  reject: (value) ->
  _process: (pending) ->
    try
      @_processCallbackFunctionOrValue pending
    catch e
      pending.rejectNext e
  _processCallbackFunctionOrValue: (pending) ->
    if @_isFunction pending.callback
      @_processCallbackFunction(pending)
    else
      pending.onValue pending.valueOrReason
  _processCallbackFunction: (pending) ->
    promiseOrValue = pending.callback pending.valueOrReason
    if @_isPromise(promiseOrValue)
      promiseOrValue.then pending.fulfillNext, pending.rejectNext
    else
      pending.fulfillNext promiseOrValue
  _schedulePendedCallbacks: (pendings)->
    for pending in pendings
      do(pending) => @_schedule_for_processing pending
  _isPromise: (p) -> @_isFunction(p?.then)
  _isFunction: (f) -> typeof f == 'function'

class FulfilledPromiseState extends ResolvedPromiseState
  constructor: (@value, pendings=[]) -> super(pendings)
  _schedule_for_processing: (pending) ->
    nextTick => @_process
      valueOrReason: @value
      callback: pending.onFulfilled
      onValue: pending.nextPromise.fulfill.bind pending.nextPromise
      fulfillNext: pending.nextPromise.fulfill.bind pending.nextPromise
      rejectNext: pending.nextPromise.reject.bind pending.nextPromise

class RejectedPromiseState extends ResolvedPromiseState
  constructor: (@reason, pendings=[]) -> super(pendings)
  _schedule_for_processing: (pending) ->
    nextTick => @_process
      valueOrReason: @reason
      callback: pending.onRejected
      onValue: pending.nextPromise.reject.bind pending.nextPromise
      fulfillNext: pending.nextPromise.fulfill.bind pending.nextPromise
      rejectNext: pending.nextPromise.reject.bind pending.nextPromise
