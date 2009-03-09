#! parrot

.sub test :main
  load_bytecode 'library/Test/More.pbc'
  .local pmc exports, curr_namespace, test_namespace
  curr_namespace = get_namespace
  test_namespace = get_namespace [ 'Test'; 'More' ]
  exports = split ' ', 'plan diag ok nok is is_deeply like isa_ok skip isnt todo'
  test_namespace.'export_to'(curr_namespace, exports)

  plan(16)

  .local pmc curry
  load_bytecode 'curry.pbc'
  curry = get_hll_global ['OCarrot'; 'Lib'; 'Curry'], 'curry'
  ok(1, 'load library')

  .local pmc curried
  .const 'Sub' noargs = 'noargs'
  .const 'Sub' echo = 'echo'
  .const 'Sub' exn_when_invoked = 'exn_when_invoked'
  .const 'Sub' addition = 'addition'

  curried = curry(noargs)
  ok(1, 'curry sub without args')
  isnt(curried, 42, 'sub without args not yet run')
  $P0 = curried()
  is($P0, 42, 'curried invoke result')
  $P1 = curried()
  is($P1, 42, 'second curried invoke, still same result')

  push_eh catch_invoke_curry
  curried = curry(exn_when_invoked)
  ok(1, 'curry does not invoke sub')
  pop_eh
  goto invoke_zero_args
catch_invoke_curry:
  ok(0, 'curry has invoked sub')

invoke_zero_args:
  push_eh catch_invoke_zero_args
  curried()
  ok(1, "invoke with not enough args does not run sub")
  pop_eh
  goto invoke_enough_args
catch_invoke_zero_args:
  ok(0, "curried sub invoked without enough args")

invoke_enough_args:
  push_eh catch_invoke
  curried(1)
  ok(0, 'curried invoke did not run sub')
  pop_eh
  goto end_exn_when_invoked
catch_invoke:
  ok(1, 'curried sub run')

end_exn_when_invoked:

  .const string hello = "Hello World!"
  .const string dalek = "Extermination!"
  curried = curry(echo)
  .local pmc result
  result = curried(hello)
  is(result, hello, 'sub result')
  result = curried(dalek)
  is(result, dalek, 'curried does not remember')

  curried = curry(addition)
  .local pmc add7, add9, add15
  add7 = curried(7)
  add9 = curried(9)
  result = curried(42, 17)
  is(result, 59, 'curried addition')
  result = add7(3)
  is(result, 10, 'curried 7 + 3')
  result = add9(15)
  is(result, 24, 'curried 9 + 15')
  result = add7(23)
  is(result, 30, 'curried 7 + 23')
  result = curried(1, 3)
  is(result, 4, 'another curried addition')
  add15 = curried(15)
  result = add15(5)
  is(result, 20, 'curried 15 + 5')
.end

.sub noargs
  .return (42)
.end

.sub exn_when_invoked
  .param pmc dumb_arg
  $P0 = new 'Exception'
  throw $P0
.end

.sub echo
  .param pmc message
  .return (message)
.end

.sub addition
  .param pmc left
  .param pmc right

  $P0 = left + right

  .return ($P0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

