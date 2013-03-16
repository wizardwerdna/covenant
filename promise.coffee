root = (exports ? this)

class Promise
  constructor: -> @state = new PendingState
  status: -> @state.status()
  fulfill: (value) -> @state = @state.fulfill(value)
  reject: (reason) -> @state = @state.reject(reason)
  then: (a,b) -> @state.then(a,b)

root.Promise = Promise

class ThennableState
  then: (onFulfill, onReject) ->
    p2 = new Promise
    @_schedule(onFulfill, onReject, p2)
    p2

class PendingState extends ThennableState
  constructor: -> @pendeds = []
  status: -> 'pending'
  fulfill: (value) -> new FulfilledState value, @pendeds
  reject: (reason) -> new RejectedState reason, @pendeds
  _schedule: (f,r,p) -> @pendeds.push [f,r,p]

class CompletedState extends ThennableState
  constructor: (pendeds) ->
    for pended in pendeds
      do(pended) => @_schedule(pended...)
  fulfill: -> @
  reject: -> @
  _do: (datum, callback, fallback, p2) ->
    if @_isFunction callback
      @_handleFunction arguments...
    else
      fallback.call p2, datum
  _handleFunction: (datum, callback, fallback, p2) ->
    try
      @_handleCallbackResults arguments...
    catch e
      p2.reject.call p2, e
  _handleCallbackResults: (datum, callback, fallback, p2) ->
    if @_isPromise result=callback(datum)
      result.then p2.fulfill.bind(p2), p2.reject.bind(p2)
    else
      p2.fulfill.call p2, result
  _isFunction: (thing)-> typeof thing is 'function'
  _isPromise: (thing)-> @_isFunction thing?.then

class FulfilledState extends CompletedState
  constructor: (@value, pended) -> super pended
  status: -> 'fulfilled'
  _schedule: (onFulfill, __, p2) ->
    process.nextTick =>
      @_do @value, onFulfill, p2.fulfill, p2

class RejectedState extends CompletedState
  constructor: (@reason, pended) -> super pended
  status: -> 'rejected'
  _schedule: (__, onReject, p2) ->
    process.nextTick =>
      @_do @reason, onReject, p2.reject, p2
