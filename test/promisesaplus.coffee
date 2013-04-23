((define)-> define (require,root)->

  {Core, Covenant, enqueue} = require('../covenant')

  describe "Run covenant against the Promises/A+ Test Suite", ->
    @slow(500)
    @timeout(250)
    require('promises-aplus-tests')?.mocha
      fulfilled: (value) -> p=new Core; p.resolve(value); p
      rejected: (reason) -> p=new Core; p.reject(reason); p
      pending: ->
        p = new Core
        promise: p
        fulfill: p.resolve
        reject: p.reject

)(if typeof define=="function" then define else if window? then (factory) => factory((->), window['Covenant']||={}) else (factory) -> factory(require, exports, module))
