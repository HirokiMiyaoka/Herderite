package HerderiteIO;

use strict;
use warnings;

use IO::FileDir;

sub new
{
	my ( $package, $param ) = @_;

	my $obj =  bless ( { param => $param }, $package );

	$obj->{ filedir } = new FileDir( $obj );

	return $obj;
}

sub decode()
{
	my ( $self ) = ( @_ );

	$self->{ get } = &CommonDecode( \($ENV{ 'QUERY_STRING' } || '') );

	my $size = $ENV{ 'CONTENT_LENGTH' } || 0;
	if ( $self->{ param }{ DATAMAX } <= 0 || $size <= $self->{ param }{ DATAMAX } )
	{
		my $data;
		read( STDIN, $data, $size );
		$self->{ post } = &CommonDecode( \$data );
	} else
	{
		$self->{ post } = {};
	}

	unless ( exists( $self->{ get }{ f } ) ){ $self->{ get }{ f } = ''; }
	unless ( exists( $self->{ get }{ b } ) ){ $self->{ get }{ b } = ''; }
	if ( exists( $self->{ get }{ d } ) && $self->{ get }{ d } =~ /(pc|sp)/ ){ $self->{ param }{ DEV } = $1; }

}

sub CommonDecode
{
	my ( $query ) = ( @_ );
	my @args = split( /&/, ${ $query } );
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

1;
