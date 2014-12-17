package Front;

use strict;
use warnings;

use Front::Html;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( {param=>$param}, $package );
}

sub out()
{
	my ( $self ) = ( @_ );

	my $html = new Html();
	my $out = $html->out();

	push( @{$self->{param}{HTTP}}, "Content-Length: " . length( $out ) );

	print @{$self->{param}{HTTP}};
	print "\n";
	print $out;
}

1;
