# Copyright (C) 2006-2009, Parrot Foundation.
# $Id: skeleton.pir 38369 2009-04-26 12:57:09Z fperrad $

.HLL 'ocarrot'

.namespace ['Pervasives']

.sub 'set_stdhandles' :anon :load :init
    $P0 = getstdin
    set_global 'stdin', $P0

    $P0 = getstdout
    set_global 'stdout', $P0

    $P0 = getstderr
    set_global 'stderr', $P0
.end

.sub 'print_char'
    .param pmc char

    $I0 = char
    $S0 = chr $I0
    print $S0
.end

.sub 'print_string'
    .param pmc text

    $S0 = text
    print $S0
.end

.sub 'print_int'
    .param pmc integer

    $I0 = integer
    print $I0
.end

.sub 'print_float'
    .param pmc number

    $N0 = number
    print $N0
.end

.sub 'print_endline'
    .param pmc text

    $S0 = text
    say $S0
.end

.sub 'print_newline'
    print "\n"

    $P0 = getstdout
    $P0.'flush'()
.end

.sub 'read_line'
    $P0 = getstdout
    $P0.'flush'()

    $P1 = getstdin
    $S0 = $P1.'readline'()
    .return ($S0)
.end

.sub 'exit'
    .param pmc exit_value

    $I0 = exit_value
    exit $I0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
