.namespace [ 'OCarrot'; 'Lib' ; 'Curry' ]

# Returns a curried version of the function passed in arg
.sub curry
  .param pmc function # The sub which we want to curry
  .param pmc args :slurpy # Some args for function

  .lex '$function', function
  .lex '@args', args

  .const 'Sub' curried = 'curried_helper'
  curried = newclosure curried
  .return (curried)
.end

.sub curried_helper :outer('curry')
  .param pmc new_args :slurpy
  .local pmc assumed_args, req_args
  .local pmc function

  assumed_args = find_lex '@args'
  function = find_lex '$function'
  req_args = inspect function, 'pos_required'

  $I1 = new_args # Number of new args
  $I2 = req_args # Number of required args
  $I3 = assumed_args # Number of previously given args
  $I4 = $I3 + $I1
  $I0 = $I2 - $I4 # Number of remaining args

  if $I0 > 0 goto curry_again
    # I don't want to care with "too many arguments"
    .tailcall function(assumed_args :flat, new_args :flat)
  curry_again:
    .tailcall curry(function, assumed_args :flat, new_args :flat)
.end
