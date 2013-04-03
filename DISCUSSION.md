## Discussion

### Using the Promise 

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

This pattern is common for node API calls with node callbacks.  Once the promise is built, a client receiving the promise can query it by registering resolution handlers.  The client may register as many handlers as the programmer likes, both before and after resolution. For example,

```coffeescript
createReadFilePromise('filename.txt').
  then console.log, console.error
```

which will log the result value to stdout upon fulfillment, or writes the error to stderr upon rejection.  Of course, this simply uses promises to do what the original API can easily do.  While there are theoretical reasons why [promises are superior to direct callbacks](http://blog.jcoglan.com/2013/03/30/callbacks-are-imperative-promises-are-functional-nodes-biggest-missed-opportunity/), the practical reasons are wonderful enough:

### The Pyramid of Doom and Chained Promises

Imagine that we have a callback-based function that takes a url and returns its data or an error message.  One Url produces information about a particular user, including an url for user's posts, which in turn contains information about comments related to that post.  We want to get date for user Jim's most recent post and all of its comments.  With traditional callbacks, this might be written

```coffeescript
http.get('/users/Jim', (err, jim) ->
  if (err)
    # handle an error trying to get jim's info
  else

    # do some stuff for jim
    http.get(jim.mostRecentPostUrl, (err, mostRecentPost) ->

      if (err)
        # duplicate of code handling error
      else

        # do some stuff for mostRecentPost
        http.get(mostRecentPost.commentsUrl, (err, comments) ->

          if (err)
            # yet another duplicate of code handling error
          else

            # do some stuff for the comments
```

The styleistic and maintenance problems with this solution are evident, particularly when you imagine more detailed structures of depending actions.  First, the rightmost drift makes this code increasingly unreadable and unmaintainable.  Second, the error handlers will be repeated with each and every call, even though at most one error handler will ever be executed.  Indeed, this problem gets even worse when separate callbacks and "errbacks" are used.

Promises provides an elegant solution to this, because .then returns a promise based upon the returned value of the callback, and hence subsequent .thens are chainable:

```coffeescript
promiseGet = Promise.fromNode(http.get)

promiseGet('/users/Jim')
.then((jim)->

  #do some stuff with jim
  promiseGet(jim.mostRecntPostUrl))

.then((mostRecentPost)->

  #do some stuff with the mostRecentPost 
  promiseGet(mostRecentPost.commentsUrl))

.then((comments)->

  #do some stuff with the comments
  )

.fail (reason) ->

  # handle the first error based on reason
```

And using aggregation functions

```coffeescript
promiseGet = Promise.fromNode(http.get)

promiseGet('/users/Jim')
.then((jim)->

  # do some stuff with jim
  Promise.all(jim, 
    promiseGet(jim.mostRecntPostUrl))

.then(([jim, mostRecentPost])->

  # do some stuff with jim AND mostRecentPost 
  Promise.all(jim, mostRecentPost, 
    promiseGet(mostRecentPost.commentsUrl))

.then(([jim, mostRecentPost, comments])->

  #do some stuff with jim, mostRecentPost and comments
  )

.fail (reason) ->

  # handle the first error based on reason

```
