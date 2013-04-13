root = (exports ? this)

root.enqueue = enqueue =
  (typeof setImmediate == 'function' && setImmediate) or
  (process?.nextTick) or
  (task) -> setTimeout(task, 0)

class Covenant
  constructor: (@then=->)->
root.Covenant = Covenant

class Core extends Covenant
  constructor: (init=->)->
    super(@then)
    @state = new PendingState
    init(@resolve, @reject, this)
  then: (onFulfill, onReject) =>
    new @constructor (res, rej, p2) =>
      @state._schedule(onFulfill, onReject, p2)
  fulfill: (value) => @state = @state.fulfill(value)
  reject: (reason) => @state = @state.reject(reason)
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
  promise: -> new Covenant @then
root.Core = Core

class PendingState
  constructor: -> @pendeds = []
  fulfill: (value) -> new FulfilledState value, @pendeds
  reject: (reason) -> new RejectedState reason, @pendeds
  _schedule: (f,r,p) -> @pendeds.push [f,r,p]

class CompletedState
  constructor: (pendeds) ->
    @_schedule(pended...) for pended in pendeds
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
