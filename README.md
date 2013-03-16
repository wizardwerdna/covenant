# oath 
<img src="http://promises-aplus.github.com/promises-spec/assets/logo-small.png" style="outline: 1pt solid brown;" align="right" /> Oath is a 64-line [Promises/A+](https://github.com/promises-aplus/promises-spec) implementation written in Coffeescript.  Oath passes the [Promises/A+ Test Suite](https://github.com/promises-aplus/promises-tests).  It compiles to under 200 lines of javascript, less than 500 bytes without compression.  

 
## Installation 

Download it, clone it, or `npm install wizardwerdna/oath`

Oath has no dependencies, but does use process.nextTick, found in modern Browsers.  If process.nextTick is not a function, Oath falls back to setImmediate, and then to setTimeout.  If you are using ancient browsers, it is highly recommended that you use a shim to implement (fake) nextTick and/or setImmediate.

## The API

```coffeescript

# get the Promise class
Oath = require('oath').Oath;

# create a new pending promise
oath = new Promise

# fulfill it
oath.fulfill(value)

# reject it
oath.reject(reason)

# schedule asynchronous handers
oath.then onFulfilled, onRejected

```

## Why another promise implementation?

I set out to write Oath, just for myself, so to achieve a better understanding of the nuances of the Promise pattern.  The Promises/A+ specification seemed elegant, but I couldn't seem to grok it without more. Reading the code of various compliant mplementations was helpful, but I still didn't seem to own it.  I began the experiment by "cowboy" coding a first set, using the test suite to verify that things were working.  Finally, I discarded that code as one to throw away, and rebuilt it in pure BDD red-green-refactor style.

Having a well-understood testbed for promises, I will probably extend oath to a more full-featured implementation.

## Credits

I am indebted, in particular, to the work of Brian Cavalier, whose 
[when.js](https://github.com/cujojs/when), and [avow.js](https://github.com/briancavalier/avow)
libraries illuminate what can be done both in a full-featured and minimalist implementation.

## Running the tests

1. clone the respository
1. `npm install`
1. `npm test`

## License

MIT License, Copyright (c) 2013 Andrew C. Greenberg (wizardwerdna@gmail.com)
