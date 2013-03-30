root = (exports ? this)
{Covenant} = require './covenant'

class Promise extends Covenant
  constructor: -> super()
  # constructors
  @makePromise: (f) -> p = new Promise; f(p); p
  @pending: => @makePromise ->
  @fulfilled: (value) => @makePromise (p)-> p.fulfill(value)
  @rejected: (reason) => @makePromise (p)-> p.reject(reason)
  @fromNode: (f)=>
    (args...) => @makePromise (p)->
      f(args..., p._nodeResolver)
  @delay: (ms)=> @makePromise (p)-> setTimeout(p.fulfill, ms)
  @timeout: (ms, p) => @makePromise (p2)->
    p.then p2.fulfill, p2.reject
    err = new Error "timeout after #{ms} milliseconds"
    setTimeout (-> p.reject err), ms
  
  # aggregate promises
  @when: (promises...) => @makePromise (pAll)=>
    pAll.results = new Array promises.length
    pAll.numLeft = promises.length
    if promises.length == 0
      pAll.fulfill []
    else
      for p, i in promises
        do(p, i) => @_scheduleResolution(pAll,p,i)
  @all: @when
  
  # convenience instance functions
  done: (onFulfill) -> @then onFulfill
  fail: (onReject) -> @then null, onReject
  always: (callback) -> @then callback, callback

  # restricted instances
  resolver: =>
    reject: @reject
    fulfill: @fulfill

  thenable: =>
    then: @then
    done: @done
    fail: @fail
    always: @always
    
  @_scheduleResolution: (pAll, valOrPromise, i) =>
    if @_isPromise(valOrPromise)
      valOrPromise.then (
        (value) => @_scheduleResolution(pAll, value, i)),
        pAll.reject
    else
      pAll.results[i] = valOrPromise
      if --pAll.numLeft == 0
        pAll.fulfill(pAll.results)

  @_isPromise: (p) -> typeof p?.then == 'function'

  _nodeResolver: (err, value) =>
    if err then @reject(err) else @fulfill(value)
root.Promise = Promise
