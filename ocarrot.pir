=head1 TITLE

ocarrot.pir - An OCaml compiler for Parrot.

=head2 Description

This is the base file for the OCarrot compiler.

This file includes the parsing and grammar rules from
the src/ directory, loads the relevant PGE libraries,
and registers the compiler under the name 'OCarrot'.

=head2 Functions

=over 4

=item onload()

Creates the OCarrot compiler using a C<PCT::HLLCompiler>
object.

=cut

.HLL 'OCarrot'

.sub '' :anon :load :init
    load_bytecode 'PCT.pbc'
    .local pmc parrotns, cns, exports

    parrotns = get_root_namespace ['parrot']
    cns = get_hll_namespace
    exports = split ' ', 'PAST PCT PGE'
    parrotns.'export_to'(cns, exports)
.end

.sub '__onload' :load :init
    $P0 = get_hll_global ['PCT'], 'HLLCompiler'
    $P1 = $P0.'new'()
    $P1.'language'('OCarrot')

    $P2 = get_hll_namespace ['OCarrot'; 'Grammar']
    $P1.'parsegrammar'($P2)
    $P2 = get_hll_namespace ['OCarrot'; 'Grammar'; 'Actions']
    $P1.'parseactions'($P2)

    $P1.'commandline_banner'("        Carrot version 0.0.0\n\n")
    $P1.'commandline_prompt'('# ')

    $P0 = new 'List'
    set_hll_global ['OCarrot';'Grammar';'Actions'], '@?BLOCK', $P0
.end

# .include 'src/gen_builtins.pir'
.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'


=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the OCarrot compiler.

=cut

.sub 'main' :main
    .param pmc args

    $P0 = compreg 'OCarrot'
    .tailcall $P0.'command_line'(args)
.end

.sub '%list'
  .param pmc fields :slurpy
  .return(fields)
.end

.sub '%array'
  .param pmc fields :slurpy
  .local pmc tablo, iter
  .local int taille, i

  tablo = new 'FixedPMCArray'
  set tablo, fields
  iter  = new 'Iterator', fields
  REDO:
  .return($P0)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

