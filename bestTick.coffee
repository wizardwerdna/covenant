#
# Utility function to select the  most efficient available "yield" operation:
#   nextTick is selected if available, then
#   setImmediate if available, or as a fallback
#   a constructed function using setTimeout with a 0ms delay
#
# If your platform is likely to revert to the fallback, it is highly recommended
# to use a setImmediate polyfil.
#

(exports ? this).bestTick =
  (process?.nextTick) or
  (typeof setImmediate == 'function' && setImmediate) or
  (task) -> setTimeout(task, 0)
