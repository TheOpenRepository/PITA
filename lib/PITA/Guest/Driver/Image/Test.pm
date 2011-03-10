package PITA::Guest::Driver::Image::Test;

use 5.008;
use strict;
use File::Spec                 ();
use Probe::Perl                ();
use PITA::Image                ();
use PITA::Guest::Driver::Image ();

our $VERSION = '0.50';
our @ISA     = 'PITA::Guest::Driver::Image';

# The location of the support server
my $image_bin = File::Spec->rel2abs(
	File::Spec->catfile( 't', 'bin', 'pita-imagetest' )
);
unless ( -f $image_bin ) {
	Carp::croak("Failed to find the pita-imagetest script");
}

# To allow for testing, whenever we return a support server we
# need to keep a reference to it.
use vars qw{$LAST_SUPPORT_SERVER};
BEGIN {
	$LAST_SUPPORT_SERVER = undef;
}

sub support_server_new {
	my $self   = shift;
	my $server = PITA::POE::SupportServer->new(
		execute => [
			Probe::Perl->find_perl_interpreter,
			$image_bin,
			'--injector',
			$self->injector_dir,
		],
		http_local_addr       => $self->support_server_addr,
		http_local_port       => $self->support_server_port,
		http_mirrors          => {},
		http_result           => $self->support_server_results,
		http_startup_timeout  => 30,
		http_activity_timeout => 60,
		http_shutdown_timeout => 30,
	) or die "Failed to create support server";

	# Save the reference to the support server
	$LAST_SUPPORT_SERVER = $server;

	return $server;
}

1;
