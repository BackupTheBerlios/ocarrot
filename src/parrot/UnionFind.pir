=head1 Union-find Data Structures

=head2 Name

['Graph'; 'UnionFind'] - union-find data-structures

=head2 Description

Union-find is a data structure for representing a collection of disjoint sets
of elements. The structure is optimized to perform quickly the operations of
merging two sets, and finding whether two elements belong to the same set.

Splitting a set or removing an element is however not allowed.

You have to make sure that two different elements of the structure
convert into different strings.

=head2 Synopsis

  .local pmc uf
  load_bytecode 'UnionFind.pbc'
  uf = new ['Graph'; 'UnionFind']

  $P0 = ... # Some PMC
  uf.'add'($P0)

  $P1 = ... # Some other PMC
  uf.'add'($P1)

  # Each element is first alone in its class, this returns false:
  $I0 = uf.'same'($P0, $P1)

  # Now, merge their classes
  uf.'merge'($P0, $P1)
  $I0 = uf.'same'($P0, $P1) # Now returns true

=cut

.namespace [ "Graph"; "UnionFind" ]

.const int PARENT = 0
.const int RANK = 1
.const int REPRESENTATIVE = 2

.sub '__onload' :anon :load :init
  $P0 = newclass [ "Graph"; "UnionFind" ]

  addattribute $P0, "table"
.end

.sub 'init' :vtable :method
  new $P0, 'Hash'
  setattribute self, "table", $P0
.end

=head2 Methods

=over 4

=item C<uf.'add'(pmc)>

Add a set containing only the element 'pmc' in the structure.

=cut

.sub 'add' :method
  .param pmc elem
  .local pmc table

  table = getattribute self, "table"
  $P0 = new 'ResizablePMCArray'
  # $P0[PARENT] is null
  $P1 = new 'Integer'
  $P1 = 0
  $P0[RANK] = $P1
  $P0[REPRESENTATIVE] = elem
  table[elem] = $P0
.end

=item C<uf.'has'(pmc)>

Returns a true value if the parameter 'pmc' is in the structure.

=cut

.sub 'has' :method
  .param pmc elem
  .local pmc table

  table = getattribute self, "table"

  $I0 = exists table[elem]
  .return ($I0)
.end

=item C<uf.'find'(pmc)>

Returns a PMC representing the set which contains 'pmc'. Two elements in the
same set have the same representative.

=cut

.sub '_parent' :method
    .param pmc elem

    $P0 = elem[PARENT]
    $I0 = isnull $P0
    if $I0 goto reached_root

    $P1 = self.'_parent'($P0)
    elem[PARENT] = $P1
    .return ($P1)

  reached_root:
    .return (elem)
.end

.sub 'find' :method
    .param pmc elem
    .local pmc table

    $I0 = self.'has'(elem)
    if $I0 goto find_it
    self.'add'(elem)
  find_it:
    table = getattribute self, "table"
    $P0 = table[elem]

    .tailcall self.'_parent'($P0)
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

  $I0 = $P0[RANK]
  $I1 = $P1[RANK]

  if $I0 > $I1 goto do_union
    exchange $P0, $P1
  do_union:
    $P1[PARENT] = $P0

    if $I0 < $I1 goto union_end
      inc $I0
      $P3 = new 'Integer'
      $P3 = $I0
      $P0[RANK] = $P3
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

=item Vtable C<get_iter>

Returns an Iterator over current equivalence classes.

=cut

.sub 'get_iter' :vtable
    .local pmc result
    .local pmc table
    .local pmc keys_iter

    result = new 'ResizablePMCArray'
    table = getattribute self, "table"
    keys_iter = iter table

  elements_loop:
    unless keys_iter goto elements_end
    $P0 = shift keys_iter
    $P1 = table[$P0]
    $P2 = $P1[PARENT]
    $I0 = isnull $P2
    unless $I0 goto elements_loop
    push result, $P0
    goto elements_loop

  elements_end:
    result = iter result
    .return (result)
.end

=item C<uf.'representative'(pmc)>

Given a class C<pmc> as argument, returns the element which represents
this class.

=cut

.sub 'representative' :method
    .param pmc elem

    $P0 = elem[REPRESENTATIVE]
    .return ($P0)
.end

=back
=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

