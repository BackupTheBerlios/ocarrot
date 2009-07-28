#!parrot

.HLL 'ocarrot'

.loadlib 'ocarrot_group'

.sub 'test' :main
    .include 'test_more.pir'

    plan(7)

    test_new_string()
    test_set_get_string()
    test_string_equality()
    test_string_boxed()
    test_string_tag()
.end

.sub 'test_new_string'
    $P0 = new 'caml_string'
    ok(1, 'new caml_string')
.end

.sub 'test_set_get_string'
    $P0 = new 'caml_string'

    $P0 = 'Hello OCarrot!'
    $S0 = 'Hello OCarrot!'

    is($P0, $S0, 'get/set string on caml_string')

    $P1 = get_class 'caml_string'
    isa_ok($P0, $P1, 'pmc still')
.end

.sub 'test_string_equality'
    $P0 = new 'caml_string'
    $P1 = new 'caml_string'
    $P2 = new 'caml_string'

    $P0 = 'This is some string'
    $P1 = 'This is another string'
    $P2 = 'This is some string'

    isnt($P0, $P1, 'different caml_strings')
    is($P0, $P2, 'equal caml_strings')
.end

.sub 'test_string_boxed'
    $P0 = new 'caml_string'

    $I0 = $P0.'is_boxed'()
    ok($I0, 'caml_string is boxed')
.end

.sub 'test_string_tag'
    $P0 = new 'caml_string'

    $I0 = $P0.'tag'()
    is($I0, 257, 'caml_string tag is String_tag')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

