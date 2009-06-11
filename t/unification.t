#! parrot

.sub test :main
    load_bytecode 'Test/More.pbc'

    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_namespace [ 'Test'; 'More' ]
    exports = split ' ', 'plan ok nok is isnt todo'
    test_namespace.'export_to'(curr_namespace, exports)

    plan(21)

    load_bytecode 'Unification.pbc'
    ok(1, 'load library')

    reflexive_constants()
    fresh_variables_are_different()
    merge_variables()
    cons_with_variable()
    cons_with_args()
    recursive_solution()
    complicated_unification()
.end

.sub new_unifier
    $P0 = new ['OCarrot'; 'Unification'; 'Constraints']
    ok(1, 'new unifier')
.end

.sub reflexive_constants
    $P0 = new ['OCarrot'; 'Unification'; 'Constraints']

    $P1 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P2 = new ['OCarrot'; 'Unification'; 'Constructor']

    $P3 = box "a constructor name"
    $P1.'name'($P3)
    $P3 = box "a constructor name"
    $P2.'name'($P3)

    $P0.'add_constraint'($P1, $P2)

    $P4 = $P0.'substitute'($P1)
    is($P4, $P1, 'no subst on first')
    $P5 = $P0.'substitute'($P2)
    is($P5, $P2, 'no subst on second')
    is($P4, $P5, 'are equal')
.end

.sub fresh_variables_are_different
    $P0 = new ['OCarrot'; 'Unification'; 'Variable']
    $P1 = new ['OCarrot'; 'Unification'; 'Variable']
    isnt($P0, $P1, 'fresh variables are different')
.end

.sub merge_variables
    $P0 = new ['OCarrot'; 'Unification'; 'Constraints']
    $P1 = new ['OCarrot'; 'Unification'; 'Variable']
    $P2 = new ['OCarrot'; 'Unification'; 'Variable']

    $P3 = $P0.'substitute'($P1)
    is($P1, $P3, 'first variable unchanged')
    $P4 = $P0.'substitute'($P2)
    is($P2, $P4, 'second variable unchanged')
    isnt($P3, $P4, 'both variables not yet merged')

    # Now, merge them
    $P0.'add_constraint'($P1, $P2)
    $P3 = $P0.'substitute'($P1)
    $P4 = $P0.'substitute'($P2)
    is($P3, $P4, 'both variables now merged')
.end

.sub cons_with_variable
    $P0 = new ['OCarrot'; 'Unification'; 'Constraints']
    $P1 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P3 = box "Cons_name"
    $P1.'name'($P3)

    $P2 = new ['OCarrot'; 'Unification'; 'Variable']

    $P0.'add_constraint'($P1, $P2)
    $P3 = $P0.'substitute'($P1)
    is($P1, $P3, 'constructor has not changed')
    $P4 = $P0.'substitute'($P2)
    is($P1, $P4, 'variable is now assigned')

    # Now, do the symmetric case
    $P0 = new ['OCarrot'; 'Unification'; 'Constraints']
    $P0.'add_constraint'($P2, $P1)
    $P3 = $P0.'substitute'($P1)
    is($P1, $P3, 'constructor has not changed (symmetric case)')
    $P4 = $P0.'substitute'($P2)
    is($P1, $P4, 'variable is now assigned (symmetric case)')
.end

.sub cons_with_args
    .local pmc uf
    .local pmc cons1
    .local pmc cons2

    uf = new ['OCarrot'; 'Unification'; 'Constraints']

    $P0 = box "A"
    cons1 = new ['OCarrot'; 'Unification'; 'Constructor']
    cons1.'name'($P0)

    # Add three arguments to our first constructor
    $P1 = new ['OCarrot'; 'Unification'; 'Variable']
    $P2 = new ['OCarrot'; 'Unification'; 'Variable']
    $P3 = new ['OCarrot'; 'Unification'; 'Variable']
    cons1.'arguments'($P1, $P2, $P3)

    # Do the same with the second constructor
    $P0 = box "A"
    cons2 = new ['OCarrot'; 'Unification'; 'Constructor']
    cons2.'name'($P0)
    $P1 = new ['OCarrot'; 'Unification'; 'Variable']
    $P2 = new ['OCarrot'; 'Unification'; 'Variable']
    $P3 = new ['OCarrot'; 'Unification'; 'Variable']
    cons2.'arguments'($P1, $P2, $P3)

    # They are not equal
    $P1 = uf.'substitute'(cons1)
    $P2 = uf.'substitute'(cons2)
    isnt($P1, $P2, "terms not yet unified")
    uf.'add_constraint'(cons1, cons2)
    $P1 = uf.'substitute'(cons1)
    $P2 = uf.'substitute'(cons2)
    is($P1, $P2, "terms now unified")
.end

.sub recursive_solution
    .local pmc uf
    .local pmc cons
    .local pmc var

    uf = new ['OCarrot'; 'Unification'; 'Constraints']
    var = new ['OCarrot'; 'Unification'; 'Variable']
    cons = new ['OCarrot'; 'Unification'; 'Constructor']
    $P0 = box "F"
    cons.'name'($P0)
    cons.'arguments'(var)

    uf.'add_constraint'(var, cons)
    ok(1, 'recursive constraint solved')

    $I0 = uf.'is_recursive'()
    ok($I0, 'solution is recursive')
.end

.sub complicated_unification
    .local pmc uf
    .local pmc vara, varb, varc, vard, vare, varf, varg
    .local pmc consG, consF, consK, consL
    .local pmc c11, c12, c21, c22, c31, c32

    uf = new ['OCarrot'; 'Unification'; 'Constraints']

    vara = new ['OCarrot'; 'Unification'; 'Variable']
    varb = new ['OCarrot'; 'Unification'; 'Variable']
    varc = new ['OCarrot'; 'Unification'; 'Variable']
    vard = new ['OCarrot'; 'Unification'; 'Variable']
    vare = new ['OCarrot'; 'Unification'; 'Variable']
    varf = new ['OCarrot'; 'Unification'; 'Variable']
    varg = new ['OCarrot'; 'Unification'; 'Variable']

    consG = box 'G'
    consF = box 'F'
    consK = box 'K'
    consL = box 'L'

    # Build the term G(F(a, b), c, d) in c11
    $P0 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P0.'name'(consF)
    $P0.'arguments'(vara, varb)
    c11 = new ['OCarrot'; 'Unification'; 'Constructor']
    c11.'name'(consG)
    c11.'arguments'($P0, varc, vard)

    # Build the term G(e, f, F(g)) in c12
    $P0 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P0.'name'(consF)
    $P0.'arguments'(varg)
    c12 = new ['OCarrot'; 'Unification'; 'Constructor']
    c12.'name'(consG)
    c12.'arguments'(vare, varf, $P0)

    # Build the term e in c21
    c21 = vare

    # Build the term F(F(c), L(a)) in c22
    $P0 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P0.'name'(consF)
    $P0.'arguments'(varc)
    $P1 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P1.'name'(consL)
    $P1.'arguments'(vara)
    c22 = new ['OCarrot'; 'Unification'; 'Constructor']
    c22.'name'(consF)
    c22.'arguments'($P0, $P1)

    # Build the term K(f,c) in c31
    c31 = new ['OCarrot'; 'Unification'; 'Constructor']
    c31.'name'(consK)
    c31.'arguments'(varf, varc)

    # Build the term K(L(F(g)), L(d)) in c32
    $P0 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P0.'name'(consF)
    $P0.'arguments'(varg)
    $P1 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P1.'name'(consL)
    $P1.'arguments'($P0)
    $P2 = new ['OCarrot'; 'Unification'; 'Constructor']
    $P2.'name'(consL)
    $P2.'arguments'(vard)
    c32 = new ['OCarrot'; 'Unification'; 'Constructor']
    c32.'name'(consK)
    c32.'arguments'($P1, $P2)

    # Now, merge for all i, ci1 and ci2
    uf.'add_constraint'(c11, c12)
    uf.'add_constraint'(c21, c22)
    uf.'add_constraint'(c31, c32)

    # The solution should be:
    # a -> F(L(F(g)))
    # b -> L(F(L(F(g))))
    # c -> L(F(g))
    # d -> F(g)
    # e -> F(F(L(F(g))), L(F(L(F(g))))
    # f -> L(F(g))
    # g -> g

    $P0 = uf.'substitute'(c11)
    $P1 = uf.'substitute'(c12)
    $P2 = uf.'substitute'(c21)
    $P3 = uf.'substitute'(c22)
    $P4 = uf.'substitute'(c31)
    $P5 = uf.'substitute'(c32)

    is($P0, $P1, 'first equality satisfied')
    is($P2, $P3, 'second equality satisfied')
    is($P4, $P5, 'third equality satisfied')

    $I0 = uf.'is_recursive'()
    nok($I0, 'solution is not recursive')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

