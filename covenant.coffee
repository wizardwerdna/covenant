root = (exports ? this)

nextTick = (process?.nextTick) or
           (typeof setImmediate == 'function' && setImmediate) or
           (task) -> setTimeout(task, 0)

class Covenant
  constructor: -> @state = new PendingState
  status: -> @state.status()
  fulfill: (value) -> @state = @state.fulfill(value)
  reject: (reason) -> @state = @state.reject(reason)
  then: (onFulfill, onReject) ->
    p2 = new Covenant
    @_schedule(onFulfill, onReject, p2)
    p2

root.Covenant = Covenant

class PendingState
  constructor: -> @pendeds = []
  status: -> 'pending'
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
      fallback.call p2, datum
  _handleFunction: (datum, callback, fallback, p2) ->
    try
      @_handleCallbackResults arguments...
    catch e
      p2.reject.call p2, e
  _handleCallbackResults: (datum, callback, fallback, p2) ->
    if @_isPromise result=callback(datum)
      result.then ((value)-> p2.fulfill(value)),
        ((reason)-> p2.reject(reason))
    else
      p2.fulfill.call p2, result
  _isFunction: (thing)-> typeof thing is 'function'
  _isPromise: (thing)-> @_isFunction thing?.then

class FulfilledState extends CompletedState
  constructor: (@value, pended) -> super pended
  status: -> 'fulfilled'
  _schedule: (onFulfill, __, p2) ->
    nextTick => @_do @value, onFulfill, p2.fulfill, p2

class RejectedState extends CompletedState
  constructor: (@reason, pended) -> super pended
  status: -> 'rejected'
  _schedule: (__, onReject, p2) ->
    nextTick => @_do @reason, onReject, p2.reject, p2
