root = (exports ? this.Covenant)

root.enqueue = enqueue =
  (typeof setImmediate == 'function' && setImmediate) or
  (process?.nextTick) or (task) -> setTimeout(task, 0)

root.Covenant = class Covenant
  constructor: (@then=->)->

root.Core = class Core extends Covenant
  constructor: (resolver=->)->
    return (new Core(resolver)) unless this instanceof Core
    throw new TypeError("resolver must be a function") unless typeof resolver == 'function'
    @_buildPromise(resolver)
  _buildPromise: (resolver) ->
    @state = new PendingState
    @promise = @promise ? new Covenant(@then)
    try
      resolver.call(this, @resolve, @reject, this)
    catch e
      @reject e
  then: (onFulfill, onReject) => new @constructor (resolve, reject) =>
    @state.schedule (state) ->
      state.then(onFulfill, onReject).then(resolve, reject)
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
      if value isnt Object(value) or typeof valueThen isnt 'function'
        @fulfill value
      else # assimilate foreign thennable, assuring callbacks run at most once
        once=do(done=false)->(f)->(x)->((done=true;f(x)) unless done)
        try
          valueThen.call value, once(@resolve), once(@reject)
        catch e
          once(@reject)(e)
    catch e
      @reject e

class PendingState
  constructor: -> @pendeds = []
  fulfill: (value) -> new FulfilledState value, @pendeds
  reject: (reason) -> new RejectedState reason, @pendeds
  schedule: (f)=> @pendeds.push f

class CompletedState
  constructor: (pendeds=[]) ->
    enqueue => pended(@) for pended in pendeds
  fulfill: -> @
  reject: -> @
  then: (onFulfilledOrRejected, valueOrReason) ->
    try
      if typeof onFulfilledOrRejected isnt 'function'
        @
      else
        new FulfilledState onFulfilledOrRejected(valueOrReason)
    catch e
      new RejectedState e
  schedule: (f)=> enqueue => f(@)
    
class FulfilledState extends CompletedState
  constructor: (@value, pended) -> super pended
  then: (onFulfill, onReject) -> super(onFulfill, @value)

class RejectedState extends CompletedState
  constructor: (@reason, pended) -> super pended
  then: (onFulfill, onReject) -> super(onReject, @reason)
