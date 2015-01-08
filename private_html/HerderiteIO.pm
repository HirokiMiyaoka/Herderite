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

sub getdevice
{
	return $ENV{ 'HTTP_USER_AGENT' } || '';
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

sub loadmarkdown()
{
	my ( $self, $file ) = ( @_ );
	return $self->{ filedir }->loadmarkdown( $file );
}

sub loadfile()
{
	my ( $self, $file ) = ( @_ );
	return $self->{ filedir }->loadfile();
}

sub getfilename()
{
	my ( $self ) = ( @_ );
	my $file = $self->{ get }{ f };

	if ( $self->{ get }{ b } ne '' )
	{
		my ( $y, $m, $d ) = ( '0000', '00', '00' );
		if ( $self->{ get }{ b } =~ /([0-9]{4})([0-9]{2})([0-9]{2})/ )
		{
			( $y, $m, $d ) = ( $1, $2, $3 );
			$file = join( '/', $self->{ param }{ BLOG }, $y, $m, $d );
		} elsif ( $self->{ io }->{ get }{ b } =~ /([0-9]{4})([0-9]{2})/ )
		{
			( $y, $m ) = ( $1, $2 );
			$file = join( '/', $self->{ param }{ BLOG }, $y, $m );
		} elsif ( $self->{ io }->{ get }{ b } =~ /([0-9]{4})/ )
		{
			$y = $1;
			$file = join( '/', $self->{ param }{ BLOG }, $y );
		} else
		{
			$file = $self->{ param }{ BLOG };
		}
		$self->{ param }{ D } = $d;
		$self->{ param }{ M } = $m;
		$self->{ param }{ Y } = $y;
	} else
	{
		my ( @time ) = localtime( time() );
		$self->{ param }{ D } = '00';#sprintf( "%02d", $time[ 3 ] );
		$self->{ param }{ M } = sprintf( "%02d", $time[ 4 ] + 1 );
		$self->{ param }{ Y } = $time[ 5 ] + 1900;
	}

	if ( $file =~ /\.\./ )
	{
		$file = $self->{ param }{ DEF };
	}

	return $file || $self->{ param }{ DEF };
}

sub checkfiledir()
{
	my ( $self, $file ) = ( @_ );
	return $self->{ filedir }->checkfiledir( $file );
}

sub getdirpath()
{
	my ( $self, $dir ) = ( @_ );
	$dir =~ s/\/{2,}/\//g;
	unless ( $dir =~ /\/$/ ){ $dir .= '/';}
	return $dir;
}

sub getparentdirpath()
{
	my ( $self, $dir ) = ( @_ );
	$dir =~ /^(.+\/)(?:[^\/]+\/)$/;
	return $1 || '';
}

sub getdirlist()
{
	my ( $self, $dir ) = ( @_ );
	return $self->{ filedir }->getdirlist( $dir );
}

1;
