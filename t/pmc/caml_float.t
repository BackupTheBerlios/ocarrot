#!parrot

.HLL 'ocarrot'

.loadlib 'ocarrot_group'

.sub 'test' :main
    .include 'test_more.pir'

    plan(9)

    test_new_float()
    test_set_get_number()
    test_set_get_string()
    test_float_equality()
    test_float_boxed()
    test_float_tag()
.end

.sub 'test_new_float'
    $P0 = new 'caml_float'
    ok(1, 'new caml_float')
.end

.sub 'test_set_get_number'
    $P0 = new 'caml_float'

    $N0 = 2.71828183
    $P0 = $N0

    $N1 = $P0
    is($N1, $N0, 'get/set number on caml_float')

    $P1 = get_class 'caml_float'
    isa_ok($P0, $P1, 'pmc still')
.end

.sub 'test_set_get_string'
    $P0 = new 'caml_float'

    $P0 = '3.14159265'
    $N0 = 3.14159265

    is($P0, $N0, 'get/set string float on caml_float')

    $P1 = get_class 'caml_float'
    isa_ok($P0, $P1, 'pmc still')
.end

.sub 'test_float_equality'
    $P0 = new 'caml_float'
    $P1 = new 'caml_float'
    $P2 = new 'caml_float'

    $P0 = 3.14159265
    $P1 = 2.71828183
    $P2 = '3.14159265'

    isnt($P0, $P1, 'different caml_floats')
    is($P0, $P2, 'equal caml_floats')
.end

.sub 'test_float_boxed'
    $P0 = new 'caml_float'

    $I0 = $P0.'is_boxed'()
    ok($I0, 'caml_float is boxed')
.end

.sub 'test_float_tag'
    $P0 = new 'caml_float'

    $I0 = $P0.'tag'()
    is($I0, 258, 'caml_float tag is Double_tag')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

