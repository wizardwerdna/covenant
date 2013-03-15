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
  status: -> 'pending'
  fulfill: (value) -> new FulfilledState value
  reject: (reason) -> new RejectedState reason

class CompletedState extends ThennableState
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
      @_handleCallbackReturningPromise result, arguments...
    else
      p2.fulfill.call p2, result
  _handleCallbackReturningPromise: (result, datum, callback, failback, p2) ->
    switch result.status()
      when 'fulfilled' then p2.fulfill result.state.value
      when 'rejected' then  p2.reject result.state.reason
      else throw new Error "nuh-uh"
  _isFunction: (thing)-> typeof thing is 'function'
  _isPromise: (thing)-> @_isFunction thing?.then

class FulfilledState extends CompletedState
  constructor: (@value) ->
  status: -> 'fulfilled'
  _schedule: (onFulfill, __, p2) ->
    @_do @value, onFulfill, p2.fulfill, p2

class RejectedState extends CompletedState
  constructor: (@reason) ->
  status: -> 'rejected'
  _schedule: (__, onReject, p2) ->
    @_do @reason, onReject, p2.reject, p2
