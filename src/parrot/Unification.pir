.include 'hllmacros.pir'

.namespace ['OCarrot'; 'Unification'; 'Variable']

.sub '' :anon :load
    $P0 = newclass ['OCarrot'; 'Unification'; 'Variable']
    addattribute $P0, "var_id"

    $P1 = get_hll_namespace ['OCarrot'; 'Unification'; 'Variable']
    $P2 = new 'Integer'
    $P2 = 0
    set_global "_var_count", $P2
.end

.sub 'init' :vtable
    $P0 = get_global '_var_count'
    $P1 = $P0 + 1
    set_global '_var_count', $P1

    setattribute self, 'var_id', $P0
.end

.sub 'get_string' :vtable
    $P0 = getattribute self, 'var_id'
    $S0 = $P0
    .return($S0)
.end

.sub 'is_equal' :vtable
    .param pmc other
    .local pmc var_class

    var_class = class self
    $I0 = isa other, var_class
    unless $I0 goto is_equal_end

    $P0 = getattribute self, 'var_id'
    $P1 = getattribute other, 'var_id'
    $I0 = iseq $P0, $P1

  is_equal_end:
    .return ($I0)
.end

.namespace ['OCarrot'; 'Unification'; 'Constructor']

.sub '' :anon :load
    $P0 = newclass ['OCarrot'; 'Unification'; 'Constructor']
    addattribute $P0, 'constructor'
    addattribute $P0, 'arguments'
.end

.sub 'get_pmc' :vtable
    $P0 = getattribute self, 'constructor'
    .return ($P0)
.end

.sub 'set_pmc' :vtable
    .param pmc newpmc
    setattribute self, 'constructor', newpmc
.end

.sub 'get_iter' :vtable
    $P0 = getattribute self, 'arguments'
    $P1 = iter $P0
    .return ($P1)
.end

.sub 'elements' :vtable
    $P0 = getattribute self, 'arguments'
    $I0 = elements $P0
    .return ($I0)
.end

.sub 'is_equal' :vtable
    .param pmc other
    .local pmc cons_class

    cons_class = class self
    $I0 = isa other, cons_class
    unless $I0 goto different

    $P0 = deref self
    $P1 = deref other
    unless $P0 == $P1 goto different
    $P0 = getattribute self, 'arguments'
    $P1 = getattribute other, 'arguments'
    unless $P0 == $P1 goto different
    .return (1)

  different:
    .return (0)
.end

.sub 'get_string' :vtable
    $P0 = getattribute self, 'constructor'
    $S0 = $P0

    $P0 = getattribute self, 'arguments'
    $S1 = join ', ', $P0

    concat $S0, '('
    concat $S0, $S1
    concat $S0, ')'
    .return ($S0)
.end

.sub 'get_pmc_keyed' :vtable
    .param pmc key

    $P0 = getattribute self, 'arguments'
    $P1 = $P0[key]
    .return ($P1)
.end

.sub 'set_pmc_keyed' :vtable
    .param pmc key
    .param pmc value

    $P0 = getattribute self, 'arguments'
    $P0[key] = value
.end

.sub 'arguments' :method
    .param pmc args :slurpy

    setattribute self, 'arguments', args
.end

.namespace ['OCarrot'; 'Unification'; 'Constraints']

.sub '' :anon :load
    load_bytecode "UnionFindValue.pbc"
    $P0 = get_class 'Hash'
    $P1 = subclass $P0, ['OCarrot'; 'Unification'; 'Constraints']
    addattribute $P1, 'env' # equivalence classes of variables
    addattribute $P1, 'constraints'
.end

.sub 'init' :vtable
    # Initialize our attribute
    $P0 = new ['Graph'; 'UnionFind'; 'WithValue']
    setattribute self, 'env', $P0
    $P1 = new 'ResizablePMCArray'
    setattribute self, 'constraints', $P1
.end

.sub 'add_constraint' :method
    .param pmc a
    .param pmc b

    .local pmc var_ns
    .local pmc env

    var_ns = get_class ['OCarrot'; 'Unification'; 'Variable']
    env = getattribute self, 'env'

    $I0 = isa a, var_ns
    $I1 = isa b, var_ns

    .If({$I0}, {
      $I2 = env.'has'(a)
      .Unless({$I2}, {
        env.'add'(a, a)
      })
    })
    .If({$I1}, {
      $I2 = env.'has'(b)
      .Unless({$I2}, {
        env.'add'(b, b)
      })
    })

    $I2 = and $I0, $I1
    if $I2 goto both_variables
    if $I0 goto a_variable_b_cons
    if $I1 goto b_variable_a_cons

  both_cons:
    # Check that the two constructors are equal
    $P0 = deref a
    $P1 = deref b
    if $P0 == $P1 goto constructors_ok
    # If we reach this place, constructors are different: throw an
    # exception.
    $P0 = box "Different constructors"
    throw $P0
  constructors_ok:
    # Check the arity
    $I0 = elements a
    $I1 = elements b
    if $I0 == $I1 goto arity_ok
    # If we reach this place, arities are different: throw an exception.
    $P0 = box "Different arities for constructor"
    throw $P0
  arity_ok:
    # Recursively check the arguments
    .local pmc itera
    .local pmc iterb
    itera = iter a
    iterb = iter b
  iter_next:
    unless itera goto iter_end
    $P0 = shift itera
    $P1 = shift iterb
    self.'add_constraint'($P0, $P1)
    goto iter_next
  iter_end:
    .return ()

  both_variables:
    # Both are unbound variables, simply merge them
    $I0 = env.'same'(a, b)
    .Unless({$I0},{
      $P0 = env.'get_value'(a)
      $P1 = env.'get_value'(b)
      env.'union'(a, b, b)
      self.'add_constraint'($P0, $P1)
    })
    .return ()

  b_variable_a_cons:
    exchange a, b # Trick to re-use the following code
  a_variable_b_cons:
    $P0 = env.'get_value'(a)
    $I0 = isa $P0, var_ns
    .IfElse($I0, {
      env.'set_value'(a, b)
    },{
      self.'add_constraint'($P0, b)
    })
    .return ()
.end

.sub 'is_recursive' :method
    # Check whether the solution is recursive
    .return (0)
.end

.sub 'substitute' :method
    .param pmc expr
    .local pmc subst
    .local pmc env
    .local pmc var_ns

    var_ns = get_hll_namespace ['OCarrot'; 'Unification'; 'Variable']
    $I0 = isa expr, var_ns

    if $I0 goto is_variable
    subst = clone expr
    $I0 = elements subst
    $I1 = 0
  next_arg:
    unless $I1 < $I0 goto cons_end
    $P1 = subst[$I1]
    $P2 = self.'substitute'($P1)
    subst[$I1] = $P2
    inc $I1
    goto next_arg
  cons_end:
    .return (subst)

  is_variable:
    env = getattribute self, 'env'
    $P0 = env.'get_value'(expr)
    $I0 = iseq $P0, expr
    .IfElse({$I0},{
      .return ($P0)
    },{
      .tailcall self.'substitute'($P0)
    })
.end
# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

