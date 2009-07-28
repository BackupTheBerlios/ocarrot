.HLL 'parrot'

.loadlib 'ocarrot_group'

.HLL 'ocarrot'

.sub 'mappings' :anon :load :init
    .local pmc interp

    interp = getinterp

    $P0 = get_class 'Integer'
    $P1 = get_class 'caml_value'
    interp.'hll_map'($P0, $P1)

    $P0 = get_class 'Float'
    $P1 = get_class 'caml_float'
    interp.'hll_map'($P0, $P1)

    $P0 = get_class 'String'
    $P1 = get_class 'caml_string'
    interp.'hll_map'($P0, $P1)

    $P0 = get_class 'Boolean'
    $P1 = get_class 'caml_value'
    interp.'hll_map'($P0, $P1)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

