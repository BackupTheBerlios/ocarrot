#!parrot

.HLL 'ocarrot'

.loadlib 'ocarrot_group'

.sub 'test' :main
    .include 'test_more.pir'

    plan(9)

    test_new_block()
    test_set_size()
    test_value_block_equality()
    test_block_boxed()
    test_set_get_tag()
    test_block_equality()
.end

.sub 'test_new_block'
    $P0 = new 'caml_block'
    ok(1, 'new caml_block')

    $I0 = $P0
    is($I0, 0, 'new caml_block is empty')
.end

.sub 'test_set_size'
    $P0 = new 'caml_block'

    $I0 = 0
    push_eh test_set_size_handler
    $P0 = 1
    $I0 = 1

  test_set_size_handler:
    nok($I0, 'cannot set the size of caml_block')
.end

.sub 'test_value_block_equality'
    $P0 = new 'caml_value'
    $P1 = new 'caml_block'

    isnt($P0, $P1, 'caml_value and caml_block differ')
.end

.sub 'test_block_boxed'
    $P0 = new 'caml_block'

    $I0 = $P0.'is_boxed'()
    ok($I0, 'caml_block is boxed')
.end

.sub 'test_set_get_tag'
    $P0 = new 'caml_block'
    $P1 = new 'caml_block'

    $P0.'tag'(17)
    $P1.'tag'(42)

    $I0 = $P0.'tag'()
    is($I0, 17, 'get tag (1/2)')

    $I1 = $P1.'tag'()
    is($I1, 42, 'get tag (2/2)')
.end

.sub 'test_block_equality'
    $P0 = new 'caml_block'
    $P1 = new 'caml_block'
    $P2 = new 'caml_block'

    $P0.'tag'(17)
    $P1.'tag'(42)
    $P2.'tag'(17)

    isnt($P0, $P1, 'caml_block with different tags differ')
    is($P0, $P2, 'equal caml_blocks')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

