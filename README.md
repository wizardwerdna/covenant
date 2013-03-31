[![Build Status](https://travis-ci.org/wizardwerdna/covenant.png)](https://travis-ci.org/wizardwerdna/covenant)
<img src="http://promises-aplus.github.com/promises-spec/assets/logo-small.png" style="outline: 1pt solid brown;" align="right" /> 


# Covenant 

Covenant is a fully compliant [Promises/A+](https://github.com/promises-aplus/promises-spec) implementation written in Coffeescript.  Covenant, its core class is a bare-bones implementation that passes the [Promises/A+ Test Suite](https://github.com/promises-aplus/promises-tests).  Covenant is extremely performant and lightweight, its three-function core being 52 lines of Coffeesript, compiling to 170 lines of javascript that minimizes to just 960 bytes uglified and compressed.  Promise, more full-featured extension of Covenant is included, weighing in at an additional 62 lines of Coffeescript. Altogether with the Core, Promise compiles to 324 lines and 1.6K bytes uglified and compressed.  
 
## The Covenant (Core) API

```coffeescript
{Covenant} = require('covenant')

# create a new promise
p = new Covenant

# fulfill it with a value
p.fulfill(value)

# reject it, with a reason (such as an Error object)
p.reject(reason)

# schedule asynchronous handlers, as often as you like, before or after resolution
# the handler may be a value, a function or a promise (an object having a function
# property named "then."
covenant.then onFulfilled, onRejected
```

## Discussion

A promise represents a `value`, that may exist now or in the future, or the `reason` why a value could not be computed.  At any point in time, a promise will be either: (i) `pending` resolution; (ii) `fulfilled` with a `value`; or (iii) `rejected` with a `reason`.  A pending object can be resolved  with the `p.fulfill` and `p.reject` functions.  Once resolved, any further call to either function is ignored. Resolution is not guaranteed, and a promise can remaining forever pending. 

A program performing an asynchronous computation may deliver its result by creating apromise and returning it to the client.  The program then manages its state by fulfilling it with a value or rejecting it with a reason as may be required.  For example, a promise for delivery of file contents might be built as follows:

```coffeescript
createReadFilePromise = (filename, encoding='utf8') ->
  p = new Covenant
  fs.readFile filename, encoding, (err, value) ->
    if err
      p.reject(err) 
    else
      p.fulfill(value)
  p
```

This pattern is common for node-style callback functions.  Once the promise is built, a client receiving the promise can query it by registering resolution handlers.  The client may register as many handlers as the programmer likes, both before and after resolution. For example,

```coffeescript
createReadFilePromise('filename.txt').
  then console.log, console.error
```

which will log the result value to stdout upon fulfillment, or writes the error to stderr upon rejection.

## Installation 

Download it, clone it, or `npm install wizardwerdna/covenant`

Covenant has no dependencies, but does use process.nextTick, found in modern Browsers.  If process.nextTick is not a function, Covenant falls back to setImmediate, and then to setTimeout.  If you are using ancient browsers, it is highly recommended that you use a shim to implement (fake) nextTick and/or setImmediate.

## Why another promise implementation?

I set out to write Covenant, just for myself, so to achieve a better understanding of the nuances of the Promise pattern.  The Promises/A+ specification seemed elegant, but I couldn't seem to grok it without more. Reading the code of various compliant mplementations was helpful, but I still didn't seem to own it.  I began the experiment by "cowboy" coding a first set, using the test suite to verify that things were working.  Finally, I discarded that code as one to throw away, and rebuilt it in pure BDD red-green-refactor style.

Having a well-understood testbed for promises, I will probably extend covenant to a more full-featured implementation.

## Credits

I am indebted, in particular, to the work of Brian Cavalier, whose [when.js](https://github.com/cujojs/when), and [avow.js](https://github.com/briancavalier/avow) libraries illuminate what can be done both in a full-featured and minimalist implementation.

## Running the tests

1. clone the respository
1. `npm install`
1. `npm test`

## License

MIT License, Copyright (c) 2013 Andrew C. Greenberg (wizardwerdna@gmail.com)
