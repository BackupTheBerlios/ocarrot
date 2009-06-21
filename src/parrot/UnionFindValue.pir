=head1 Union-find Hash

=head2 Name

['Graph'; 'UnionFind'; 'WithValue'] - union-find hash

=head2 Description

This structur extends union-find structures by allowing one to associate
a value to each equivalence class.

=head2 Synopsis

  .local pmc uf
  load_bytecode 'UnionFindValue.pbc'
  uf = new ['Graph'; 'UnionFind'; 'WithValue']

  $P0 = ... # Some PMC
  uf.'add'($P0)
  uf.'set_value'($P0, some_value) # Sets the value of $P0's class
  $P1 = uf.'get_value'($P0) # Gives back some_value

=cut

.include 'UnionFind.pir'
.namespace ['Graph'; 'UnionFind'; 'WithValue']

.const int VALUE = 3

.sub '' :anon :load :init
    $P0 = get_class ['Graph'; 'UnionFind']
    $P1 = subclass $P0, ['Graph'; 'UnionFind'; 'WithValue']
.end

# Helper method to call our parent's methods
.sub '__super' :method
    .param string name
    .param pmc args :slurpy

    $P0 = class self
    $P1 = $P0.'parents'()
    $P2 = $P1[0]
    $P3 = $P2.'find_method'(name)
    .tailcall self.$P3(args :flat)
.end

=head2 Methods

=over 4

=item C<uf.'add'(pmc, value :optional)>

Adds an element to the structure, and give it the value C<value>. The
value is the element itself when C<value> is not provided.

=cut

.sub 'add' :method
    .param pmc elem
    .param pmc value :optional
    .local pmc table

    self.'__super'('add', elem)

    table = getattribute self, "table"
    $P0 = table[elem]

    $I0 = isnull value
    unless $I0 goto push_it
    value = elem
  push_it:
    $P0[VALUE] = value
.end

=item C<uf.'union'(elem1, elem2, value :optional)

Merges the classes of C<elem1> and C<elem2>, and sets the value of the
resulting class to C<value>. When C<value> is not provided, it is set to
Null.

=cut

.sub 'union' :method
    .param pmc elem1
    .param pmc elem2
    .param pmc value :optional

    self.'__super'('union', elem1, elem2)

    .local pmc table
    table = getattribute self, 'table'

    $P0 = table[elem1]
    $P1 = $P0[VALUE]
    $P0 = table[elem2]
    $P1 = $P0[VALUE]
    $P0 = self.'find'(elem1)
    $P0[VALUE] = value
.end

=item C<uf.'get_value'(elem)>

Gets the value associated with C<elem>'s class.

=cut

.sub 'get_value' :method
    .param pmc elem

    $P0 = self.'find'(elem)
    $P1 = $P0[VALUE]
    .return ($P1)
.end

.sub 'set_value' :method
    .param pmc elem
    .param pmc value

    $P0 = self.'find'(elem)
    $P0[VALUE] = value
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

