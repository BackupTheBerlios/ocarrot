#! perl
# Copyright (C) 2009 The Perl Foundation

=head1 TITLE

gen_parrot.pl - script to obtain and build Parrot for OCarrot (borrowed from
Rakudo).

=head2 SYNOPSIS

    perl gen_parrot.pl

=head2 DESCRIPTION

Gets the latest SVN copy of Parrot in the parrot/ subdirectory.

=cut

use strict;
use warnings;
use 5.008;

#  Work out slash character to use.
my $slash = $^O eq 'MSWin32' ? '\\' : '/';

print "Checking out latest Parrot revision via svn...\n";
system(qw(svn checkout https://svn.parrot.org/parrot/trunk parrot));

chdir('parrot');


##  If we have a Makefile from a previous build, do a 'make realclean'
if (-f 'Makefile') {
    my %config = read_parrot_config();
    my $make = $config{'make'};
    if ($make) {
        print "Performing '$make realclean'\n";
        system($make, "realclean");
    }
}

##  Configure Parrot
system($^X, "Configure.pl");

my %config = read_parrot_config();
my $make = $config{'make'};

system($make);

sub read_parrot_config {
    my %config = ();
    if (open my $CFG, "config_lib.pasm") {
        while (<$CFG>) {
            if (/P0\["(.*?)"], "(.*?)"/) { $config{$1} = $2 }
        }
        close $CFG;
    }
    %config;
}

