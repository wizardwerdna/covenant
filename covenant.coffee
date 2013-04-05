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
  resolve: (value) =>
    if value instanceof Covenant
      value.then @fulfill, @reject
    else
      @_resolveNonCovenantValue value
  _resolveNonCovenantValue: (value) =>
    try
      valueThen = value?.then
      if typeof valueThen is 'function'
        valueThen @resolve, @reject
      else
        @fulfill value
    catch e
      @reject e

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
  _runCallback: (datum, callback, fallback, p2) ->
    try
      if typeof callback is 'function'
        p2.resolve callback(datum)
      else
        fallback(datum)
    catch e
      p2.reject e

class FulfilledState extends CompletedState
  constructor: (@value, pended) -> super pended
  _schedule: (onFulfill, __, p2) ->
    enqueue => @_runCallback @value, onFulfill, p2.fulfill, p2

class RejectedState extends CompletedState
  constructor: (@reason, pended) -> super pended
  _schedule: (__, onReject, p2) ->
    enqueue => @_runCallback @reason, onReject, p2.reject, p2
