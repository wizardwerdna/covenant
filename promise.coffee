root = (exports ? this)

class Promise extends require('./covenant').Covenant
  @when: (promises...) ->
    masterPromise = new Promise
    masterResults = new Array promises.length
    promisesFulfilled = 0
    for p, i in promises
      do(p, i) ->
        p.then (
          (value) ->
            masterResults[i] = value
            if ++promisesFulfilled == promises.length
              masterPromise.fulfill(masterResults)),
          (reason) ->
            masterPromise.reject(reason)
    masterPromise
  done: (onFulfill) -> @then onFulfill
  fail: (onReject) -> @then null, onReject
  always: (callback) -> @then callback, callback
root.Promise = Promise
