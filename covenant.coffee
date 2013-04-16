root = (exports ? this)

root.enqueue = enqueue =
  (typeof setImmediate == 'function' && setImmediate) or
  (process?.nextTick) or (task) -> setTimeout(task, 0)

root.Covenant = class Covenant
  constructor: (@then=->)->

root.Core = class Core extends Covenant
  constructor: (resolver=->)->
    throw new TypeError("resolver must be a function") unless typeof resolver == 'function'
    @state = new PendingState
    try
      resolver.call(this, @resolve, @reject, this)
    catch e
      @reject e
  then: (onFulfill, onReject) => new @constructor (resolve, reject) =>
    @state.resolveThen(onFulfill, onReject, resolve, reject)
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
      if value is Object(value) and typeof valueThen is 'function'
        @_assimilateForeignThenable value, valueThen
      else
        @fulfill value
    catch e
      @reject e
  _assimilateForeignThenable: (value, valueThen)=>
    called = false
    try
      valueThen.call value,
        (value) => unless called
          called = true
          @resolve(value)
      , (reason) => unless called
        called = true
        @reject(reason)
    catch e
      unless called
        called = true
        @reject e
  promise: -> new Covenant @then

class PendingState
  constructor: -> @pendeds = []
  fulfill: (value) -> new FulfilledState value, @pendeds
  reject: (reason) -> new RejectedState reason, @pendeds
  resolveThen: (onF, onR, res, rej) ->
    @pendeds.push (state) ->
      state.resolveThen(onF, onR, res, rej)

class CompletedState
  constructor: (pendeds) ->
    pended(@) for pended in pendeds
  fulfill: -> @
  reject: -> @
  resolveThen: (datum, callback, fallback, resolve, reject) ->
    try
      if typeof callback is 'function'
        resolve callback(datum)
      else
        fallback(datum)
    catch e
      reject e

class FulfilledState extends CompletedState
  constructor: (@value, pended) -> super pended
  resolveThen: (onFulfill, _, res, rej) ->
    enqueue => super @value, onFulfill, res, res, rej

class RejectedState extends CompletedState
  constructor: (@reason, pended) -> super pended
  resolveThen: (_, onReject, res, rej) ->
    enqueue => super @reason, onReject, rej, res, rej
