[![Build Status](https://travis-ci.org/wizardwerdna/covenant.png)](https://travis-ci.org/wizardwerdna/covenant)
<img src="http://promises-aplus.github.com/promises-spec/assets/logo-small.png" style="outline: 1pt solid brown;" align="right" /> 


# Covenant 

Covenant is a fully compliant [Promises/A+](https://github.com/promises-aplus/promises-spec) implementation written in Coffeescript.  Covenant, its core class is a bare-bones implementation that passes the [Promises/A+ Test Suite](https://github.com/promises-aplus/promises-tests), as well as the present draft of version 1.1 of the test suite.  Covenant's core is very performant and extremely lightweight.  
## The Covenant (Core) API

```coffeescript
{Covenant, Core} = require('covenant')

# create a new promise, which can be figured using subsequent
# subsequent calls to the fulfill, reject and resolve methods
p = new Core 

# the promise can be configured with a callback function, which
# will be passed a resolution and rejection function, as well as
# a reference to the promise itself. Also, `this` is set to reference
# the promise.

pDelay50ms = new Core (resolve, reject, promise) ->
  setTimeout -> (
    resolve('50 milliseconds have passed'), 50)

# fulfill the promise with a value
p.fulfill(value)

# reject the promise with a reason
p.reject(reason)

# Wrap another promise or foreign "thennable" and adopt its state.
# Otherwise, fulfill with the value or reject if unable to adopt.
# Works with Promise/A+-conforming and many non-conforming promises.
p.resolve(promiseThennableOrValue)


# schedule asynchronous handlers, as often as you like, before or after resolution
# the handler may be a value, a function or a promise (an object having a function
# property named "then."
covenant.then onFulfilled, onRejected

# A Covenant object with a single `then` method linked to the promise.
# The promise can be passed to a client authorized to schedule callbacks
# on the Core object, but will not be able to change its state.
p.promise
```

## The Promise (Extended) API

Promise, more full-featured extension of Covenant's core is included, although it is in pre-alpha form at this time.  It provides: a nice collection of promise-generating operations, an aggregation function, some convenience functions and functions for securely sharing promise objects with clients for limited use.
  
### Promise Generation Functions

```coffeescript
{Promise} = require ('promise')

# Promise.pending(): construct a pending promise
p = Promise.pending()
  .anything(console.log) # => nothing yet!
  .fulfill("I'm all done") # => I'm all done"

# Promise.fulfilled(value): construct a promise fulfilled with value
Promise.fulfilled(42)
  .done(console.log) # => 43

# Promise.rejected(reason): construct a promise rejected for reason
Promise.rejected("naughty you")
  .fail(console.error) # => "naughty you"

# Promise.fromNode(nodeOperation): construct a promise generating function based on node functions
f = Promise.fromNode(fs.readFile)
pReadFile = f('foo.data')

# construct a promise that fulfills after ms milliseconds
Promise.delay(100)

# construct a promise that rejects for timeout unless resolved before ms milliseconds.
Promise.timeout(p, 100)
```

### Aggregate Promise Functions
```coffeescript
# Promise.when(promiseOrValueList): Construct a promise from any number of values or promises, which fulfills with an
# array of corresponding values if all promises are fulfilled, and rejects if ANY

# example when promise is rejected
# with raw values
Promise.when(1, 2, 3)
  .done console.log # => [1, 2, 3]

# with pending promises, ultimately fulfilled
p = Promise.pending()
q = Promise.when p, 2, Promise.fulfilled(3)
q.done console.log # => nothing happens
p.fulfill(1) # => [1,2,3] after a tick or two

# with pending promises, one rejectedl
Promise.when(Promise.pending(), Promise.fulfilled(2), Promise.rejected("Error in 3")
  .fail(console.error) # => Error in 3
p = (Promise.when p1, p2, p3).fail(console.error) # => Error in 3

# Promise.all(valueOrPromiseList): same as Promise.all Promise.when 
```

### Promise Instance Convenience Functions
```coffeescript
# p.done(callback): convenience function for p.then onFulfill, undefined
p.done(onFulfill)

# p.fail(callback): convenience function for p.then undefined, onReject
p.fail(onReject)

# p.always(callback): convenience function for p.then callback, callback
p.always(callback)

# Note that the promise returned by p.always(callback) can resolve
# differently, even when p has already resolved.
```

## Installation 

Download it, clone it, or `npm install wizardwerdna/covenant`

Covenant has no dependencies, but does use process.nextTick, found in modern Browsers.  If process.nextTick is not a function, Covenant falls back to setImmediate, and then to setTimeout.  If you are using ancient browsers, it is highly recommended that you use a shim to implement (fake) nextTick and/or setImmediate.

## Credits

I am indebted, in particular, to the work of Brian Cavalier, whose [when.js](https://github.com/cujojs/when), and [avow.js](https://github.com/briancavalier/avow) libraries illuminate what can be done both in a full-featured and minimalist implementation.

## Running the tests

1. clone the respository
1. `npm install`
1. `npm test`
1. `npm run-script browserTest`

The browser test will run the tests directly on Safari, Chrome, Firefox and phantomJS.
Some configuration of `karma.conf.js` will be necessary if you haven't configured one
or more of the browsers.  phantomJS was installed when you ran `npm install`.

## License

MIT License, Copyright (c) 2013 Andrew C. Greenberg (wizardwerdna@gmail.com)
