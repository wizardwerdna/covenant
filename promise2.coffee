root = (exports ? this)

class Promise
  constructor: -> @state = new PendingState
  status: -> @state.status()
  reject: -> @state = @state.reject()
  fulfill: -> @state = @state.fulfill()
root.Promise = Promise

class State
  constructor: ->
  reject: -> @
  fulfill: -> @

class PendingState extends State
  status: -> 'pending'
  reject: -> new RejectedState
  fulfill: -> new FulfilledState

class RejectedState extends State
  status: -> 'rejected'

class FulfilledState extends State
  status: -> 'fulfilled'
