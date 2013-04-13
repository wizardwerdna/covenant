root = (exports ? this)
{Covenant, Core} = window ? require './covenant'

class Promise extends Core
  constructor: (state, init)-> super(state, init)
  # constructors
  @makePromise: (f) -> p = new Promise; f(p); p
  @pending: => @makePromise ->
  @fulfilled: (value) => @makePromise (p)-> p.fulfill(value)
  @rejected: (reason) => @makePromise (p)-> p.reject(reason)
  @fromNode: (f)=>
    (args...) => @makePromise (p)->
      f(args..., p._nodeResolver)
  @delay: (ms)=> @makePromise (p)->
    setTimeout(p.fulfill, ms)
    p.always -> clearTimeout(t)
  @timeout: (ms, p) => @makePromise (p2)->
    err = new Error "timeout after #{ms} milliseconds"
    t = setTimeout (-> p2.reject err), ms
    p.then p2.fulfill, p2.reject
    p2.always -> clearTimeout(t)
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

  # node stream interface
  # stream: (options) => new PromiseStream @, options

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
  _httpResolver: (res) =>
    if res.statusCode == 201
      res.pipe(@stream())
    else
      @reject new Error "HTTP status code #{res.statusCode}"

root.Promise = Promise
