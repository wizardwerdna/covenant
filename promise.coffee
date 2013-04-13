root = (exports ? this)
{Covenant, Core} = window ? require './covenant'

class Promise extends Core
  constructor: (init)-> super(init)
  # constructors
  @pending: => new Promise
  @fulfilled: (value) => new Promise (resolve)-> resolve(value)
  @rejected: (reason) => new Promise (__, reject)-> reject(reason)
  @fromNode: (f)=>
    (args...) => new Promise (_, __, p)->
      f(args..., p._nodeResolver)
  @delay: (ms)=> new Promise (resolve, __, p)->
    setTimeout((->resolve(ms)), ms)
    p.always -> clearTimeout(t)
  @timeout: (ms, p) => new Promise (resolve, reject, p2)->
    err = new Error "timeout after #{ms} milliseconds"
    t = setTimeout (-> reject err), ms
    resolve(p)
    p2.always -> clearTimeout(t)
  # aggregate promises
  @when: (promises...) => new Promise (resolve, reject, pAll)=>
    pAll.results = new Array promises.length
    pAll.numLeft = promises.length
    if promises.length == 0
      resolve []
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
