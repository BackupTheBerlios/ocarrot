.namespace ['OCarrot'; 'Unification']

.sub '' :anon :load
    load_bytecode 'P6object.pbc'
    .local pmc p6meta
   p6meta = get_hll_global 'P6metaclass'

.end

.namespace ['OCarrot'; 'Unification'; 'Variable']

.sub '' :anon :load
    $P0 = newclass ['OCarrot'; 'Unification'; 'Variable']
.end

.namespace ['OCarrot'; 'Unification'; 'Constructor']

.sub '' :anon :load
    $P0 = newclass ['OCarrot'; 'Unification'; 'Constructor']
    addattribute $P0, 'constructor'
    addattribute $P0, 'arguments'
.end

.namespace ['OCarrot'; 'Unification'; 'Constraints']

.sub '' :anon :load
    $P0 = get_class 'ResizablePMCArray'
    $P1 = subclass $P0, ['OCarrot'; 'Unification'; 'Constraints']
    addattribute $P1, 'env'
    addattribute $P1, 'unifier'
.end

.sub 'add_constraint' :method
    .param pmc a
    .param pmc b

    .local pmc var_ns
    .local pmc cons_ns
    var_ns = get_namespace ['OCarrot'; 'Unification'; 'Variable']
    cons_ns = get_namespace ['OCarrot'; 'Unification'; 'Constructor']

    $I0 = isa a, var_ns
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

