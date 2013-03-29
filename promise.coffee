root = (exports ? this)
ins = (x) -> require('util').inspect x, false, null, true

class Promise extends require('./covenant').Covenant
  constructor: -> super()
  @fromNode: (f)->
    (args...) ->
      p = new Promise
      args.push (err, value) ->
        if err then p.reject(err) else p.fulfill(value)
      f(args...)
      p
  @pending: -> new Promise
  @fulfilled: (value) -> p=new Promise; p.fulfill(value); p
  @rejected: (reason) -> p=new Promise; p.reject(reason); p
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
  done: (onFulfill) -> @then onFulfill
  fail: (onReject) -> @then null, onReject
  always: (callback) -> @then callback, callback
root.Promise = Promise
