=head1 OCarrot's compiler

OCarrot::Compiler - HLLCompiler, with a specific treatment for
interactive sessions

=head2 DESCRIPTION

OCarrot::Compiler redefines the standard input's C<readline_interactive>
method before calling PCT::HLLCompiler's C<interactive> method.

Unlike the latter, we only try here to parse input when it has something
which may look like a statement, i.e., something which ends with two
semi-columns, which do not lie in a comment nor a string.

This only affects interactive sessions since, when compiling a file,
statements do not have to end with these semi-columns (the grammar does
not need them to separate statements).

=head2 OVERRIDEN METHODS

=over 4

=item C<interactive(...)>

This methods changes the standard input (using
C<ParrotInterpreter.stdhandle>) before calling our parent's
C<interactive>.

=back

=cut

.include 'stdio.pasm'
.include 'hllmacros.pir'

.sub '' :anon :init :load
    .local pmc p6meta
    load_bytecode "P6object.pbc"
    load_bytecode 'PCT/HLLCompiler.pbc'
    p6meta = new 'P6metaclass'
    p6meta.'new_class'('OCarrot::Compiler', 'parent' => 'PCT::HLLCompiler')
.end

.namespace ['OCarrot'; 'Compiler']

.sub 'interactive' :method
    .param pmc adverbs :slurpy :named
    .local pmc stdin

    # Set the new stdin to our custom parser
    $P0 = getinterp
    stdin = $P0.'stdhandle'(.PIO_STDIN_FILENO)
    $P1 = new ['OCarrot'; 'Toplevel'; 'Stdin']
    assign $P1, stdin
    $P0.'stdhandle'(.PIO_STDIN_FILENO, $P1)

    $P2 = get_hll_global ['PCT'; 'HLLCompiler'], 'interactive'
    $P2(self, adverbs :named :flat)

    # Restore stdin
    $P0.'stdhandle'(.PIO_STDIN_FILENO, stdin)
.end

=head1 OCarrot; Toplevel; Stdin

This class imitates a regular C<FileHandle>, but stops at OCaml's
statements, instead of new lines. It does not subclass C<FileHandle>,
but defines enough methods to cheat C<PCT::HLLCompiler>.

This class reads data from a C<FileHandle>, stored in the C<filehandle>
attribute.

=head1 METHODS

=over 4

=cut
.namespace ['OCarrot'; 'Toplevel'; 'Stdin']

.sub '' :anon :init :load
    $P0 = newclass ['OCarrot'; 'Toplevel'; 'Stdin']
    addattribute $P0, 'filehandle'
.end

=item C<get_bool() :vtable>

Ask our C<filehandle> attribute whether we've reached EOF or not.

=cut

.sub 'get_bool' :method :vtable
    $P0 = getattribute self, 'filehandle'
    $I0 = istrue $P0
    .return($I0)
.end

=item C<assign_pmc(handle) :vtable>

Set our C<filehandle> attribute to some PMC. Input will be read from
this PMC.

=cut

.sub 'assign_pmc' :vtable :method
    .param pmc handle
    setattribute self, 'filehandle', handle
.end

=item C<readline_interactive(prompt)>

Reads a statement from the C<filehandle> attribute. Statements can
contain newlines, and end with two consecutive semi-columns.

Yet, we also have to care about comments (which start with C<(*> and end
with C<*)> and may be nested), and strings (only between double quotes),
since two semi-columns in any of these should not be considered as
ending the statement. This method implements a simple automaton, with a
counter for comments, to decide when it has reached the end of a
statement.

=cut

.sub 'readline_interactive' :method
    .param pmc prompt
    .local pmc handle
    .local string result
    .local int comments
    .local pmc state
    .local pmc current_line

    handle = getattribute self, 'filehandle'
    current_line = new 'String'
    comments = 0
    result = ''
    state = new 'Continuation'
    set_addr state, state_initial

  next_line:
    current_line = handle.'readline_interactive'(prompt)
    $I2 = isnull current_line
    .If($I2,{ .return(current_line) })
    $I0 = -1
    $I1 = elements current_line
  next_char:
    inc $I0
    if $I0 >= $I1 goto line_end
    $S1 = current_line[$I0]
    # Call the current state
    state()

  line_end:
    # Append the result to the previous string, and get next line
    $S0 = current_line
    concat result, $S0
    concat result, " "
    prompt = "> "
    goto next_line

  state_initial:
    # Initial state: we stay there except in the following four cases
    .If($S1 == '(', {set_addr state, state_lparen})
    .If($S1 == '*', {set_addr state, state_star})
    .If($S1 == '"', {set_addr state, state_quote})
    .If($S1 == ';', {
      .If(comments == 0, {set_addr state, state_semicol})
    })
    goto next_char # goto next_char ?

  state_lparen:
    # Just seen an open parenthesis
    .If($S1 == '*', inc comments)
    set_addr state, state_initial
    goto next_char

  state_star:
    # Seen a star, which might signal the end of a comment
    set_addr state, state_initial
    .If($S1 == ')', {
      .IfElse(comments > 0,{
        dec comments
      }, {
        noop
      })
    })
    goto next_char

  state_quote:
    # Getting inside a string
    .If($S1 == '"', {set_addr state, state_initial})
    .If($S1 == '\\', {set_addr state, state_escape})
    goto next_char

  state_escape:
    # Escaping a char in a string: we juste have to consume it and
    # return to the quote state
    set_addr state, state_quote

  state_semicol:
    # First semi-column seen
    .If($S1 == ';',{
      # Here's the end of our statement
      $S0 = current_line
      concat result, $S0
      concat result, " "
      .return(result)
    })
    set_addr state, state_initial
    goto next_char

.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

