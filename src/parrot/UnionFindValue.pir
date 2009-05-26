.namespace ['Graph'; 'UnionFind'; 'WithValue']

.sub '' :anon :load
    load_bytecode 'UnionFind.pbc'
    $P0 = get_class ['Graph'; 'UnionFind']
    $P1 = subclass $P0, ['Graph'; 'UnionFind'; 'WithValue']
.end

.sub 'super' :method
    .param string name
    .param pmc args :slurpy

    $P0 = class self
    $P1 = $P0.'parents'()
    $P2 = $P1[0]
    $P3 = $P2.'find_method'(name)
    .tailcall self.$P3(args :flat)
.end

.sub 'add' :method
    .param pmc elem
    .param pmc value :optional
    .local pmc table

    self.'super'('add', elem)

    table = getattribute self, "table"
    $P0 = table[elem]

    $I0 = isnull value
    unless $I0 goto push_it
    value = elem
  push_it:
    push $P0, value
.end

.sub 'union' :method
    .param pmc elem1
    .param pmc elem2
    .param pmc value :optional

    self.'super'('union', elem1, elem2)

    .local pmc table
    table = getattribute self, 'table'

    $P0 = table[elem1]
    $P1 = pop $P0
    $P0 = table[elem2]
    $P1 = pop $P0
    $P0 = self.'find'(elem1)
    push $P0, value
.end

.sub 'get_value' :method
    .param pmc elem

    $P0 = self.'find'(elem)
    $P1 = $P0[2]
    .return ($P1)
.end

.sub 'set_value' :method
    .param pmc elem
    .param pmc value

    $P0 = self.'find'(elem)
    $P0[2] = value
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

