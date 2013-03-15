root = (exports ? this)

class Promise
  constructor: -> @state = new PendingState
  status: -> @state.status()
  fulfill: (value) -> @state = @state.fulfill(value)
  reject: (reason) -> @state = @state.reject(reason)
  then: (a,b) -> @state.then(a,b)

root.Promise = Promise

class State
  constructor: ->
  reject: -> @
  fulfill: -> @

class PendingState extends State
  status: -> 'pending'
  fulfill: (value) -> new FulfilledState value
  reject: (reason) -> new RejectedState reason

class CompletedState extends State
  do: (datum, callback, fallback, p2) ->
    if @_isNonFunction callback
      fallback datum
    else
      try
        if @_isPromise result=callback(datum)
          switch result.status()
            when 'fulfilled' then p2.fulfill result.state.value
            when 'rejected' then  p2.reject result.state.reason
            else throw new Error "nuh-uh"
        else
          p2.fulfill.bind(p2) result
      catch e
        p2.reject.bind(p2) e
  _isPromise: (thing)-> typeof thing?.then is 'function'
  _isNonFunction: (thing)-> typeof thing isnt 'function'

class FulfilledState extends CompletedState
  constructor: (@value) ->
  status: -> 'fulfilled'
  then: (onFulfill, __) ->
    p2 = new Promise
    @do @value, onFulfill, p2.fulfill.bind(p2), p2
    p2

class RejectedState extends CompletedState
  constructor: (@reason) ->
  status: -> 'rejected'
  then: (__, onReject) ->
    p2 = new Promise
    @do @reason, onReject, p2.reject.bind(p2), p2
    p2
