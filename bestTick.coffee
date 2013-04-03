#
# Utility function to select the  most efficient available "yield" operation:
#   nextTick is selected if available, then
#   setImmediate if available, or as a fallback
#   a constructed function using setTimeout with a 0ms delay
#
# If your platform is likely to revert to the fallback, it is highly recommended
# to use a setImmediate polyfil.
#
# Version 0.10 of Node changed the semantics of nextTick so that the callback ran
# before yielding to IO and the eventloop.  This high priority rendered a very
# protective view about "recursive" nextTicking, printing an annoying warning message
# and a promise to break the code in subsequent versions.  Accordingly, an alternative
# to bestTick that doesn't preempt the event loop (secondBestTick) is also provide
#
root = (exports ? this)

root.bestTick =
  (process?.nextTick) or
  (typeof setImmediate == 'function' && setImmediate) or
  (task) -> setTimeout(task, 0)

root.secondBestTick =
  (typeof setImmediate == 'function' && setImmediate) or
  (task) -> setTimeout(task, 0)

