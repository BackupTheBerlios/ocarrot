#!parrot

.HLL 'ocarrot'

.loadlib 'ocarrot_group'

.sub 'test' :main
    .include 'test_more.pir'

    plan(8)

    test_new_array()
    test_newpmc_array()
    test_array_equality()
    test_array_boxed()
    test_array_tag()
.end

.sub 'test_new_array'
    $P0 = new 'caml_array'
    ok(1, 'new caml_array')
.end

.sub 'test_newpmc_array'
    .local pmc array_class
    array_class = get_class 'caml_array'

    $P0 = root_new ['parrot'; 'ResizablePMCArray']
    push $P0, 1
    push $P0, 17
    push $P0, 42

    $P1 = new 'caml_array', $P0
    isa_ok($P1, array_class, 'pmc')

    # Test size 
    $I0 = $P0
    $I1 = $P1
    is($I0, $I1, 'caml_array has the right size')

    # Test elements
    $I0 = $P0
    $I1 = 0
    $I2 = 1
  test_array_elements_loop:
    unless $I1 < $I0 goto test_array_elements_end
    $P2 = $P0[$I1]
    $P3 = $P1[$I1]
    $I3 = iseq $P2, $P3
    $I2 = and $I2, $I3
    inc $I1
    goto test_array_elements_loop
  test_array_elements_end:
    ok($I2, 'caml_array has the right elements')
.end

.sub 'test_array_equality'
    .local pmc array1, array2, array3
    $P0 = root_new ['parrot'; 'ResizablePMCArray']
    push $P0, 1
    push $P0, 17
    push $P0, 42

    $P1 = root_new ['parrot'; 'ResizablePMCArray']
    push $P1, 1
    push $P1, 17
    push $P1, 43

    $P2 = root_new ['parrot'; 'FixedPMCArray']
    $P2 = 3
    $P2[0] = 1
    $P2[1] = 17
    $P2[2] = 43

    array1 = new 'caml_array', $P0
    array2 = new 'caml_array', $P1
    array3 = new 'caml_array', $P2

    isnt(array1, array2, 'different caml_arrays')
    is(array1, array3, 'equal caml_arrays')
.end

.sub 'test_array_boxed'
    $P0 = new 'caml_array'

    $I0 = $P0.'is_boxed'()
    ok($I0, 'caml_array is boxed')
.end

.sub 'test_array_tag'
    $P0 = new 'caml_array'

    $I0 = $P0.'tag'()
    $I1 = le $I0, 255
    ok($I1, 'tag says caml_array should be scanned by GC')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

