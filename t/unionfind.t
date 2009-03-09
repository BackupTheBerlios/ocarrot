#! parrot

.sub test :main
    load_bytecode 'library/Test/More.pbc'

    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_namespace [ 'Test'; 'More' ]
    exports = split ' ', 'plan diag ok nok is is_deeply like isa_ok skip isnt todo'
    test_namespace.'export_to'(curr_namespace, exports)

    plan(20)

    load_bytecode 'UnionFind.pbc'
    ok(1, 'load library')

    .local pmc uf

    $P0 = get_class ['Graph'; 'UnionFind']
    uf = new $P0
    ok(1, 'new UnionFind')

    .const 'Integer' elem1 = '1'
    .const 'Integer' elem2 = '2'
    .const 'Integer' elem3 = '3'
    .const 'Integer' elem4 = '4'

    uf.'add'(elem1)
    ok(1, 'add element')
    $I0 = uf.'same'(elem1, elem1)
    ok($I0, 'same is reflexive')

    uf.'add'(elem2)
    $I0 = uf.'same'(elem1, elem2)
    nok($I0, 'elements are disjoint first')

    uf.'merge'(elem1, elem2)
    $I0 = uf.'same'(elem1, elem2)
    ok($I0, 'merging elements')
    $I0 = uf.'same'(elem2, elem1)
    ok($I0, 'same is symmetric')

    uf.'add'(elem3)
    $I0 = uf.'same'(elem1, elem2)
    ok($I0, 'merged elements do not split')

    $I0 = uf.'same'(elem2, elem3)
    nok($I0, 'disjoint classes')
    $I0 = uf.'same'(elem1, elem3)
    nok($I0, 'disjoint classes')

    uf.'add'(elem4)
    uf.'merge'(elem3, elem4)
    $I0 = uf.'same'(elem3, elem4)
    ok($I0, 'second class merge')
    $I0 = uf.'same'(elem1, elem4)
    nok($I0, 'two disjoint classes')

    uf.'merge'(elem1, elem4)
    $I0 = uf.'same'(elem1, elem2)
    ok($I0, 'first class no split')
    $I0 = uf.'same'(elem3, elem4)
    ok($I0, 'second class no split')
    $I0 = uf.'same'(elem1, elem3)
    ok($I0, 'same class (1 and 3)')
    $I0 = uf.'same'(elem1, elem4)
    ok($I0, 'same class (1 and 4)')
    $I0 = uf.'same'(elem2, elem3)
    ok($I0, 'same class (2 and 3)')
    $I0 = uf.'same'(elem2, elem4)
    ok($I0, 'same class (2 and 4)')

    # Now, do the same thing, in a different order
    uf = new $P0
    uf.'add'(elem1)
    uf.'add'(elem2)
    uf.'add'(elem3)
    uf.'add'(elem4)

    uf.'merge'(elem1, elem2)
    uf.'merge'(elem3, elem4)
    uf.'merge'(elem2, elem4) # here is the difference
    $I0 = uf.'same'(elem1, elem2)
    $I1 = uf.'same'(elem3, elem4)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem1, elem3)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem1, elem4)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem2, elem3)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem2, elem4)
    $I0 = $I0 && $I1
    ok($I0, 'merge in a different order')

    # Again
    uf = new $P0
    uf.'add'(elem1)
    uf.'add'(elem2)
    uf.'add'(elem3)
    uf.'add'(elem4)

    uf.'merge'(elem1, elem2)
    uf.'merge'(elem3, elem4)
    uf.'merge'(elem1, elem3) # here is the difference
    $I0 = uf.'same'(elem1, elem2)
    $I1 = uf.'same'(elem3, elem4)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem1, elem3)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem1, elem4)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem2, elem3)
    $I0 = $I0 && $I1
    $I1 = uf.'same'(elem2, elem4)
    $I0 = $I0 && $I1
    ok($I0, 'merge in again a different order')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

