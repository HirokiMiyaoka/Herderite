package Front;

use strict;
use warnings;

use Front::Html;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub getdecode
{
	my ( $self ) = ( @_ );

	$self->{ get } = &CommonDecode( exists ( $ENV{ 'QUERY_STRING' } ) ? $ENV{ 'QUERY_STRING' } : '' );
}

sub CommonDecode( \$ )
{
	my ( $query ) = ( @_ );
	my @args = split( /&/, $query );
	my %ret;
	foreach ( @args )
	{
		unless( $_ =~ /\=/ ){next;}
		my ( $name, $val ) = split( /=/, $_, 2 );
		$val =~ tr/+/ /;
		$val =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
		unless ( exists ( $ret{ $name } ) )
		{
			$ret{ $name } = $val;
		} else
		{
			unless ( ref ( $ret{ $name } ) =~ /^ARRAY/ )
			{
				my $tmp = $ret{ $name };
				delete ( $ret{ $name } );
				$ret{ $name }[ 0 ] = $tmp;
			}
			push ( @{ $ret{$name} }, $val );
		}
	}

	return \%ret;
}

sub out()
{
	my ( $self ) = ( @_ );

	my $html = new Html();
	my $out = $html->out();

	push( @{$self->{param}{HTTP}}, "Content-Length: " . length( $out ) . "\n" );

	print @{$self->{param}{HTTP}};
	print "\n";
	print $out;
}

1;
