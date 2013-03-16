# oath 

Oath is a 64-line coffeescript based 
[Promises/A+](https://github.com/promises-aplus/promises-spec) implementation.  Oath passes the [Promises/A+ Test Suite](https://github.com/promises-aplus/promises-tests).  It compiles to under 200 lines of javascript, less than 500 bytes without compression.  It uses process.nextTick, falling back to setImmediate and setTimeout when nextTick not available, by shim or otherwise.

 
## Installation 

Download it, clone it, or `npm install git://github.com/wizardwerdna/oath.git`

## The API

```coffeescript

# get the Promise class
Promise = require('oath').Promise;

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

I set out to write Oath, just for myself, so to achieve a better understanding of the nuances of the Promise pattern.  The Promises/A+ specification seemed elegant, but I couldn't seem to grok it without more. Reading the code of various compliant mplementations was helpful, but I still didn't seem to own it.  The presence of an excellent test suite allowed me to cowboy code fairly quickly, and helped me to understand the significance of the nuances of the test.  Finally, I discarded that code as one to throw away, and rebuilt it in pure BDD red-green-refactor style.

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
