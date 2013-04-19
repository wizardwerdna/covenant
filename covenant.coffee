root = (exports ? this.Covenant)

root.enqueue = enqueue =
  (typeof setImmediate == 'function' && setImmediate) or
  (process?.nextTick) or (task) -> setTimeout(task, 0)

root.Covenant = class Covenant
  constructor: (@then=->)->

root.Core = class Core extends Covenant
  constructor: (resolver=->)->
    return (new Core(resolver)) unless this instanceof Covenant
    throw new TypeError("resolver must be a function") unless typeof resolver == 'function'
    @state = new PendingState
    try
      resolver.call(this, @resolve, @reject, this)
    catch e
      @reject e
  then: (onFulfill, onReject) => new @constructor (resolve, reject) =>
    @state.applyThen(onFulfill, onReject, resolve, reject)
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
  promise: -> new Covenant @then

class PendingState
  constructor: -> @pendeds = []
  fulfill: (value) -> new FulfilledState value, @pendeds
  reject: (reason) -> new RejectedState reason, @pendeds
  applyThen: (onFulfilled, onRejected, resolve, reject) ->
    @pendeds.push (state) ->
      state.then(onFulfilled, onRejected).then(resolve, reject)

class CompletedState
  constructor: (pendeds=[]) ->
    enqueue => pended(@) for pended in pendeds
  fulfill: -> @
  reject: -> @
  then: (valueOrReason, onFulfilledOrRejected) ->
    try
      if typeof onFulfilledOrRejected isnt 'function'
        @
      else
        new FulfilledState onFulfilledOrRejected(valueOrReason)
    catch e
      new RejectedState e
  applyThen: (onFulfilled, onRejected, resolve, reject) ->
    enqueue => @.then(onFulfilled, onRejected).then(resolve, reject)
    
class FulfilledState extends CompletedState
  constructor: (@value, pended) -> super pended
  then: (onFulfill, onReject) ->
    super(@value, onFulfill)

class RejectedState extends CompletedState
  constructor: (@reason, pended) -> super pended
  then: (onFulfill, onReject) ->
    super(@reason, onReject)
