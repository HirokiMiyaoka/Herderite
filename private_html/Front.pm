package Front;

use strict;
use warnings;

use Front::Html;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub getdevice
{
	my $ua = $ENV{ 'HTTP_USER_AGENT' } || '';
}

sub getdecode
{
	my ( $self ) = ( @_ );

	$self->{ get } = &CommonDecode( $ENV{ 'QUERY_STRING' } || '' );

	unless ( exists( $self->{ get }{ f } ) ){ $self->{ get }{ f } = ''; }
	unless ( exists( $self->{ get }{ b } ) ){ $self->{ get }{ b } = ''; }
	if ( exists( $self->{ get }{ d } ) && $self->{ get }{ d } =~ /(pc|sp)/ ){ $self->{ param }{ DEV } = $1; }
}

sub init
{
	my ( $self ) = ( @_ );
	$self->getdevice();
	$self->getdecode();
}

sub CommonDecode
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

sub out
{
	my ( $self ) = ( @_ );

	my $file = $self->{ get }{ f };

	if ( $self->{ get }{ b } =~ /([0-9]{4})([0-9]{42})([0-9]{42})/ )
	{
		$file = join( '/', $self->{ param }{ BLOG }, $1, $2, $3 );
	} elsif ( $file =~ /\.\./ )
	{
		$file = '';
	} elsif ( $file eq '' )
	{
		$file = $self->{ param }{ DEF };
	}

	if ( $file ne '' )
	{
		$file = $self->{ param }{ DIR } . '/' . $file . '.md';
		unless ( -r $file ){ $file = ''; }
	}
	$self->{ param }{ file } = $file;

	my $html = new Html( $self->{ param }, $self->{ get } );
	my $out;

	if ( $file ne '' )
	{
		$out = $html->out();
	} else
	{
		$out = $html->error( 404 );
	}

	push( @{ $self->{ param }{ HTTP } }, "Content-Length: " . length( $out ) . "\n" );

	print @{ $self->{ param }{ HTTP } };
	print "\n";
	print $out;
}

1;
