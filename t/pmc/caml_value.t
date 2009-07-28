#!parrot

.HLL 'ocarrot'

.loadlib 'ocarrot_group'

.sub 'test' :main
    .include 'test_more.pir'

    plan(9)

    test_new_value()
    test_set_integer()
    test_set_string()
    test_value_equality()
    test_value_boxed()
.end

.sub 'test_new_value'
    $P0 = new 'caml_value'
    ok(1, 'new caml_value')
.end

.sub 'test_set_integer'
    $P0 = new 'caml_value'

    $P0 = 1
    ok(1, 'set integer on caml_value')

    $I0 = $P0
    is($I0, 1, 'get integer on caml_value')

    $P0 = 2
    $I0 = $P0
    is($I0, 2, 'override integer in caml_value')
.end

.sub 'test_set_string'
    $P0 = new 'caml_value'

    $P0 = '32'
    $I0 = $P0
    is($I0, 32, 'get/set string on caml_value')

    $P1 = get_class 'caml_value'
    isa_ok($P0, $P1, 'still a caml_value after get/set string')
.end

.sub 'test_value_equality'
    $P0 = new 'caml_value'
    $P1 = new 'caml_value'
    $P2 = new 'caml_value'

    $P0 = 1
    $P1 = 2
    $P2 = 1

    isnt($P0, $P1, 'different caml_values')
    is($P0, $P2, 'equal caml_values')
.end

.sub 'test_value_boxed'
    $P0 = new 'caml_value'

    $I0 = $P0.'is_boxed'()
    nok($I0, 'caml_value is not boxed')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

