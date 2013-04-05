root = (exports ? this)

root.enqueue = enqueue =
  (typeof setImmediate == 'function' && setImmediate) or
  (process?.nextTick) or
  (task) -> setTimeout(task, 0)

class Covenant
  constructor: -> @state = new PendingState
  fulfill: (value) => @state = @state.fulfill(value)
  reject: (reason) => @state = @state.reject(reason)
  then: (onFulfill, onReject) =>
    p2 = new @constructor
    @state._schedule(onFulfill, onReject, p2)
    p2
root.Covenant = Covenant

class PendingState
  constructor: -> @pendeds = []
  fulfill: (value) -> new FulfilledState value, @pendeds
  reject: (reason) -> new RejectedState reason, @pendeds
  _schedule: (f,r,p) -> @pendeds.push [f,r,p]

class CompletedState
  constructor: (pendeds) ->
    for pended in pendeds
      do(pended) => @_schedule(pended...)
  fulfill: -> @
  reject: -> @
  _do: (datum, callback, fallback, p2) ->
    if @_isFunction callback
      @_handleFunction arguments...
    else
      fallback(datum)
  _handleFunction: (datum, callback, fallback, p2) ->
    try
      @_handleFunctionResult arguments...
    catch e
      p2.reject e
  _handleFunctionResult: (datum, callback, fallback, p2) ->
    if @_isPromise result=callback(datum)
      result.then p2.fulfill, p2.reject
    else
      p2.fulfill result
  _isFunction: (thing)-> typeof thing is 'function'
  _isPromise: (thing)-> @_isFunction thing?.then

class FulfilledState extends CompletedState
  constructor: (@value, pended) -> super pended
  _schedule: (onFulfill, __, p2) ->
    enqueue => @_do @value, onFulfill, p2.fulfill, p2

class RejectedState extends CompletedState
  constructor: (@reason, pended) -> super pended
  _schedule: (__, onReject, p2) ->
    enqueue => @_do @reason, onReject, p2.reject, p2
