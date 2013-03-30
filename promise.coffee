root = (exports ? this)
{Covenant} = require './covenant'

class Promise extends Covenant
  constructor: -> super()
  # constructors
  @pending: -> new Promise
  @fulfilled: (value) -> p=new Promise; p.fulfill(value); p
  @rejected: (reason) -> p=new Promise; p.reject(reason); p
  
  # wrappers
  @fromNode: (f)->
    (args...) ->
      p = new Promise
      args.push (err, value) ->
        if err then p.reject(err) else p.fulfill(value)
      f(args...)
      p
  
  # temporal promises
  @delay: (ms)->
    p = new Promise
    setTimeout (->p.fulfill()), ms
    p
  @timeout: (ms, p) ->
    setTimeout (->p.reject new Error "timeout after #{ms} milliseconds"), ms
    p
  
  # aggregate promises
  @all: @when
  @when: (promises...) ->
    pAll = @pending()
    pAll.results = new Array promises.length
    pAll.numLeft = promises.length
    if promises.length == 0
      pAll.fulfill []
    else
      for p, i in promises
        do(p, i) => @_scheduleResolution(pAll,p,i)
    pAll
  
  # convenience instance functions
  done: (onFulfill) -> @then onFulfill
  fail: (onReject) -> @then null, onReject
  always: (callback) -> @then callback, callback
  
    
  @_scheduleResolution: (pAll, valOrPromise, i) =>
    if @_isPromise(valOrPromise)
      do (pAll) => valOrPromise.then (
        (value) => @_scheduleResolution(pAll, value, i)),(
        (reason) => pAll.reject(reason))
    else
      pAll.results[i] = valOrPromise
      if --pAll.numLeft == 0
        pAll.fulfill(pAll.results)
  @_isPromise: (p) -> typeof p?.then == 'function'

root.Promise = Promise
