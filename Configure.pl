#! perl
# Copyright (C) 2009 The Perl Foundation

=head1 NAME

Configure.pl - a configure script for a high level language running on Parrot

=head1 SYNOPSIS

  perl Configure.pl --help

  perl Configure.pl

  perl Configure.pl --parrot_config=<path_to_parrot>

  perl Configure.pl --gen-parrot

=cut

use 5.008;
use strict;
use warnings;

# core Perl 5 modules
use File::Spec  ();

my %valid_options = (
    'help'          => 'Display configuration help',
    'parrot-config' => 'Use configuration given by parrot_config binary',
);

my @parrot_config_exe = qw(
  parrot_install/bin/parrot_config
  ../../parrot_config
  parrot_config
);

#  Get any options from the command line
my %options = get_command_options();

# Set the path to parrot_config if provided
if ($options{'parrot-config'} && $options{'parrot-config'} ne '1') {
  @parrot_config_exe = ($options{'parrot-config'});
}

# Print help if it's requested
if ($options{'help'}) {
    print_help();
    exit(0);
}

# Get configuration information from parrot_config
my %config = read_parrot_config(@parrot_config_exe);

my $parrot_errors = '';
if (!%config) { 
  $parrot_errors .= "Unable to locate parrot_config\n"; 
}

if ($parrot_errors) {
  die <<"END";
===SORRY!===
$parrot_errors
END
}

# Create the Makefile using the information we just got
create_files(
  \%config,
  { 'build/Makefile.in'                => 'Makefile' }
);

#  Done.
my $make = $config{'make'};
print <<"END";

You can now use '$make' to build OCarrot.
After that, you can use '$make test' to run some local tests.

END

exit 0;

#  Process command line arguments into a hash.
sub get_command_options {
    my %options = ();
    for my $arg (@ARGV) {
        if ($arg =~ /^--(\w[-\w]*)(?:=(.*))?/ && $valid_options{$1}) {
            my ($key, $value) = ($1, $2);
            $value = 1 unless defined $value;
            $options{$key} = $value;
            next;
        }
        die qq/Invalid option "$arg".  See "perl Configure.pl --help" for valid options.\n/;
    }
    return %options;
}

sub read_parrot_config {
  my @parrot_config_exe = @_;
  my %config;
  for my $exe (@parrot_config_exe) {
    no warnings;
    if (open my $parrot_config_fh, '-|', "$exe --dump") {
      print "Reading configuration information from $exe\n";
      while (<$parrot_config_fh>) {
        if (/(\w+) => '(.*)'/) { $config{$1} = $2 }
      }
      close $parrot_config_fh;

      if (%config) {
        my $parrot_config_exe;
        $parrot_config_exe     ||= File::Spec->rel2abs($exe);
        $parrot_config_exe     ||= File::Spec->rel2abs("$exe$config{EXE}");
        $parrot_config_exe     ||= $exe;
        $config{parrot_config_exe} = $parrot_config_exe;
        last;
      }
    }
  }

  return %config;
}


#  Generate a Makefile from a configuration
sub create_files {
    my ($config, $setup) = @_;

    while (my ($template_fn, $target_fn) = each %{$setup}) {
        my $content;
        {
            open my $template_fh, '<', $template_fn or
                die "Unable to read $template_fn.";
            $content = join('', <$template_fh>);
            close $template_fn;
        }

        $config->{'win32_libparrot_copy'} = $^O eq 'MSWin32' ? 'copy $(BUILD_DIR)\libparrot.dll .' : '';
        $content =~ s/@(\w+)@/$config->{$1}/g;
        if ($^O eq 'MSWin32') {
            $content =~ s{/}{\\}g;
        }

        print "Creating $target_fn from $template_fn.\n";
        {
            open(my $target_fh, '>', $target_fn) 
                or die "Unable to write $target_fn\n";
            print $target_fh $content;
            close($target_fh);
        }
    }
}

#  Print some help text.
sub print_help {
    print <<'END';
Configure.pl - OCarrot Configure

General Options:
    --help             Show this text
    --gen-parrot       Download and build a copy of Parrot to use
    --parrot-config=(config)
                       Use configuration information from config

END
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
