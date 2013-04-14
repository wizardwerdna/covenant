root = (exports ? this)
{Covenant} = window ? require '../../covenant'
inspect = (x)->x
# inspect = if window?
#   (x) -> x
# else
#   util = require 'util'
#   (x) -> util.inspect x, false, 3, true
covenantTestHelper = (_chai, util) ->
  Assertion = _chai.Assertion
  Assertion.addProperty 'covenant', ->
    @assert @_obj instanceof Covenant,
      "expected #{inspect @_obj} to be a Covenant",
      "expected #{@_obj} to not be a Covenant"
  Assertion.addProperty 'fulfilled', ->
    new Assertion(@_obj).to.be.a.covenant
    @assert @_obj.state?.value?,
      "expected #{inspect @_obj} to be fulfilled",
      "expected #{inspect @_obj}.value not to be fulfilled",
  Assertion.addMethod 'withValue', (value)->
    new Assertion(@_obj).to.be.a.covenant
    new Assertion(@_obj).to.be.fulfilled
    @assert value == @_obj.state?.value,
      "expected promise to be fulfilled with value #{inspect value}, but got #{inspect @_obj.state.value}",
      "expected promise not to be fulfilled with value #{value}"
  Assertion.addProperty 'rejected', ->
    new Assertion(@_obj).to.be.a.covenant
    @assert @_obj.state?.reason?,
      "expected #{inspect @_obj} to be rejected",
      "expected #{inspect @_obj}.reason not to be rejected",
  Assertion.addMethod 'withReason', (reason)->
    new Assertion(@_obj).to.be.a.covenant
    new Assertion(@_obj).to.be.rejected
    @assert reason == @_obj.state?.reason,
      "expected promise to be rejected with reason #{inspect reason}, but got #{inspect @_obj.state.reason}",
      "expected promise not to be rejected with reason #{inspect reason}"
  Assertion.addProperty 'pending', ->
    new Assertion(@_obj).not.to.be.fulfilled
    new Assertion(@_obj).not.to.be.rejected

root.covenantTestHelper = covenantTestHelper
