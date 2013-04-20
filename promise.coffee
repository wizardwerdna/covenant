root = (exports ? this.Covenant)
{Covenant, Core} = window?.Covenant ? require './covenant'

extend = (consumer, provider) ->
  consumer[k]=v for own k,v of provider
  consumer

class Promise extends Core
  constructor: (resolver)->
    return (new Promise resolver) unless this instanceof Covenant
    super(resolver)
    extend @promise, done: @done, fail: @fail, always: @always
  # constructors
  @pending: => new Promise
  @fulfilled: (value) => new Promise (resolve)-> resolve(value)
  @rejected: (reason) => new Promise (__, reject)-> reject(reason)
  @fromNode: (f)=>
    (args...)=> new Promise ->
      f(args..., @._nodeResolver)
  @delay: (ms)=> new Promise ->
    setTimeout((=>@resolve(ms)), ms)
    @always -> clearTimeout(t)
  @timeout: (ms, p) => new Promise (resolve, reject)->
    err = new Error "timeout after #{ms} milliseconds"
    t = setTimeout (-> reject err), ms
    resolve(p)
    @always -> clearTimeout(t)
  # aggregate promises
  @of: (a)=>
    if a instanceof Covenant
      a
    else new Promise (res) -> res a
  @map: (promises, f) =>
    new Promise (resolve, reject, pAll) ->
      pAll.results = []
      pAll.numLeft = promises.length
      if promises.length == 0
        resolve []
      else
        for p, i in promises
          do(p, i) =>
            Promise.of(p).then(f).then (value) ->
              pAll.results[i] = value
              if --pAll.numLeft == 0 then resolve(pAll.results)
            , (reason) -> reject(reason)
  @all: (promises...) => @map promises, (x)->x
  @reduce: (promises, f, initialValue) -> new Promise (resolve, reject)->
    Promise.of(promises).then (array) ->
      if array.length > 0 or initialValue?
        result = Promise.of(initialValue ? array.shift())
        while next = array.shift()
          result = do(result,next) ->
            result.then (acc) ->
              Promise.of(next).then (val) ->
                f(acc, val)
        resolve result
      else
        reject new TypeError (
          "resolve on empty array without an initial value")
  @inject: @reduce

#convenience instance functions
  done: (onFulfill) -> @then onFulfill
  fail: (onReject) -> @then null, onReject
  always: (callback) -> @then callback, callback

  @_isPromise: (p) -> typeof p?.then == 'function'

  _nodeResolver: (err, value) =>
    if err then @reject(err) else @fulfill(value)

  _httpResolver: (res) =>
    if res.statusCode == 201
      res.pipe(@stream())
    else
      @reject new Error "HTTP status code #{res.statusCode}"

root.Promise = Promise
