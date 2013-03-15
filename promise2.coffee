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
  _isPromise: (thing)-> typeof thing?.then is 'function'
  _isNonFunction: (thing)-> typeof thing isnt 'function'

class PendingState extends State
  status: -> 'pending'
  fulfill: (value) -> new FulfilledState value
  reject: (reason) -> new RejectedState reason

class FulfilledState extends State
  constructor: (@value) ->
  status: -> 'fulfilled'
  then: (onFulfill, __) ->
    p2 = new Promise
    if @_isNonFunction onFulfill
      p2.fulfill(@value)
    else
      try
        if @_isPromise result=onFulfill(@value)
          switch result.status()
            when 'fulfilled' then p2.fulfill result.state.value
            when 'rejected' then  p2.reject result.state.reason
            else throw new Error "nuh-uh"
        else
          p2.fulfill result
      catch e
        p2.reject(e)
    p2

class RejectedState extends State
  constructor: (@reason) ->
  status: -> 'rejected'
  then: (__, onReject) ->
    p2 = new Promise
    if @_isNonFunction onReject 
      p2.reject(@reason)
    else
      try
        if @_isPromise result=onReject(@reason)
          switch result.status()
            when 'fulfilled' then p2.fulfill result.state.value
            when 'rejected' then  p2.reject result.state.reason
            else throw new Error "nuh-uh"
        else
          p2.fulfill result
      catch e
        p2.reject(e)
    p2
