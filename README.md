# oath 

Oath is a 69-line coffeescript based 
[Promises/A+](https://github.com/promises-aplus/promises-spec) implementation.  Oath passes the [Promises/A+ Test Suite](https://github.com/promises-aplus/promises-tests).  It compiles to about 180 lines of javascript, less than 500 bytes without compression.  It uses process.nextTick, falling back to setImmediate and setTimeout when nextTick not available.

## Why another promise implementation?

I set out to write Oath, just for myself, so to achieve a better understanding of the nuances of the Promise pattern.  The Promises/A+ specification seemed elegant and comprehensible to me, but I couldn't seem to grok it without more. Reading the code of various compliant mplementations was helpful, but I still didn't seem to own it. 

I am indebted, in particular, to the work of Brian Cavalier, whose 
[when.js](https://github.com/cujojs/when), and [avow.js](https://github.com/briancavalier/avow)
libraries illuminate what can be done both in a full-featured and minimalist implementation. I
drew heavily from the inspiration of those works.  That said, Brian's functional implemention in 
avow seemed opaque to me, so I undertook to implement a more object-oriented solution to see 
if I could refactor it in a way I can comprehend.  It is my hope that this may help others 
to fathom the mysteries of asynchrony.

It was also a fun experiment to develop from a large detailed specification, rather than
implementing this in a pure BDD, red, green refactor style.  I may repeat the experiment
in in the traditional manner, using the spec only as an integration test and see how the
design turns out.  At the moment, I consider the code to have been "cowboyed, with tests,"
justified by the effort to fathom a new concept.

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

## Running the tests

1. clone the respository
1. `npm install`
1. `npm test`

## License

MIT License, Copyright (c) 2013 Andrew C. Greenberg (wizardwerdna@gmail.com)
