root = (exports ? this)

nextTick = (process?.nextTick) or
           (typeof setImmediate == 'function' && setImmediate) or
           (task) -> setTimeout(task, 0)

class Promise
  constructor: (@promise=new PendingPromise)->
  fulfill: (value) -> @promise = @promise.fulfill value
  reject: (reason) -> @promise = @promise.reject reason
  then: (onFulfilled, onRejected) -> @promise.then onFulfilled, onRejected

root.Promise = Promise

class Thenable
  then: (onFulfilled, onRejected) ->
    promise2 = new Promise
    @_schedule_for_processing
      onFulfilled: onFulfilled
      onRejected: onRejected
      nextPromise: promise2
    promise2

class PendingPromise extends Thenable
  constructor: -> @pendings = []
  fulfill: (value)-> new FulfilledPromise value, @pendings
  reject: (reason)-> new RejectedPromise reason, @pendings
  _schedule_for_processing: (params) -> @pendings.push params

class CompletedPromise extends Thenable
  constructor: (pendings)->
    for pending in pendings
      do(pending) =>
        @_schedule_for_processing(pending)
  fulfill: (value) -> @
  reject: (value) -> @
  _isPromise: (p) -> typeof p?.then == 'function'
  _process: (pending) ->
    try
      if typeof pending.callback == 'function'
        result = pending.callback(pending.data)
        if @_isPromise(result)
          result.then pending.nextPromise.fulfill.bind(pending.nextPromise),
                      pending.nextPromise.reject.bind(pending.nextPromise)
        else
          pending.nextPromise.fulfill(result)
      else
        pending.fallback.bind(pending.nextPromise) pending.data
    catch e
      pending.nextPromise.reject(e)

class FulfilledPromise extends CompletedPromise
  constructor: (@value, pendings=[]) -> super(pendings)
  _schedule_for_processing: (pending) ->
    nextTick => @_process
      data: @value
      callback: pending.onFulfilled
      nextPromise: pending.nextPromise
      fallback: pending.nextPromise.fulfill

class RejectedPromise extends CompletedPromise
  constructor: (@reason, pendings=[]) -> super(pendings)
  _schedule_for_processing: (pending) ->
    nextTick => @_process
      data: @reason
      callback: pending.onRejected
      nextPromise: pending.nextPromise
      fallback: pending.nextPromise.reject
