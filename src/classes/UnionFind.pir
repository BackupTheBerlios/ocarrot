=head1 NAME

Graph;UnionFind - union-find data-structures

=head1 DESCRIPTION

Union-find is a data structure for representing a collection of disjoint sets
of elements. The structure is optimized to perform quickly the operations of
merging two sets, and finding whether two elements belong to the same set.

Splitting a set or removing an element is however not allowed.

=head1 SYNOPSIS

  .local pmc uf

  load_bytecode "union-find.pbc"

  uf = new ['Graph'; 'UnionFind']

=cut

.namespace [ "Graph"; "UnionFind" ]

.sub '__onload' :anon :load
  $P0 = newclass [ "Graph"; "UnionFind" ]

  addattribute $P0, "table"
.end

.sub 'init' :vtable :method
  new $P0, 'Hash'
  setattribute self, "table", $P0
.end

=head1 METHODS

=over 4

=item C<uf.'add'(pmc)>

Add a set containing only the element 'pmc' in the structure.

=cut

.sub 'add' :method
  .param pmc elem
  .local pmc table

  table = getattribute self, "table"
  $P0 = new 'Array'
  $P0 = 2
  $P0[0] = $P0
  $P1 = new 'Integer'
  $P1 = 0
  $P0[1] = $P1
  table[elem] = $P0
.end

=item C<uf.'has'(pmc)>

Checks if the parameter 'pmc' is in the structure.

=cut

.sub 'has' :method
  .param pmc elem
  .local pmc table

  table = getattribute self, "table"

  $I0 = exists table[elem]
  .return ($I0)
.end

.sub '_parent' :method
  .param pmc elem

  $P0 = elem[0]
  eq_addr $P0, elem, root
    $P1 = self.'_parent'($P0)
    $P0[0] = $P1
    .return ($P1)
  root:
    .return (elem)
.end

=item C<uf.'find'(pmc)>

Returns a PMC representing the set which contains 'pmc'. Two elements in the
same set have the same representant.

=cut

.sub 'find' :method
  .param pmc elem
  .local pmc table

  table = getattribute self, "table"
  $P0 = table[elem]

  $P1 = self.'_parent'($P0)
  .return ($P1)
.end

=item C<uf.'union'(pmc1, pmc2)>

Merges the sets which contain 'pmc1' and 'pmc2'.

=cut

.sub 'union' :method
  .param pmc elem1
  .param pmc elem2
  .local pmc table

  $P0 = self.'find'(elem1)
  $P1 = self.'find'(elem2)

  $I0 = $P0[1]
  $I1 = $P1[1]

  if $I0 > $I1 goto do_union
    exchange $P0, $P1
  do_union:
    $P1[0] = $P0

    if $I0 < $I1 goto union_end
      inc $I0
      $P3 = new 'Integer'
      $P3 = $I0
      $P0[1] = $P3
  union_end:
.end

=item C<uf.'same'(pmc1, pmc2)>

Checks whether the two parameters belong to the same set.

=cut

.sub 'same' :method
  .param pmc elem1
  .param pmc elem2
  .local pmc table

  table = getattribute self, "table"

  $P0 = self.'find'(elem1)
  $P1 = self.'find'(elem2)

  $I0 = issame $P0, $P1
  .return($I0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

