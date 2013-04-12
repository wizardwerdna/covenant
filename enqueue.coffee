root = (exports ? this)

nextTick = process.nextTick
root.enqueue = do(queue=undefined)->
  trampoline = ->
    while next = queue.shift()
      next()
    queue = undefined

  (f) ->
    if queue?
      queue.push f
    else
      queue = [f]
      nextTick -> trampoline()
