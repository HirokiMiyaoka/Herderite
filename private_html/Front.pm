package Front;

use strict;
use warnings;

use URI::Escape;

use Front::Markdown;
use Front::Template;
use Front::Blog;
use Front::Tool;

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

sub init
{
	my ( $self ) = ( @_ );
	$self->getdevice();
	$self->getdecode();
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
		} elsif ( $self->{ get }{ b } =~ /([0-9]{4})([0-9]{2})/ )
		{
			( $y, $m ) = ( $1, $2 );
			$file = join( '/', $self->{ param }{ BLOG }, $y, $m );
		} elsif ( $self->{ get }{ b } =~ /([0-9]{4})/ )
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
		$file = '';
	}

	return $file;
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
	return my $parent = $1 || '';
}

sub getdirlist()
{
	my ( $self, $dir ) = ( @_ );

	my $basedir = $self->{ param }{ DIR } . '/' . $dir;
	opendir( DIR, $basedir );
	my @list = sort{ $a cmp $b }( readdir( DIR ) );
	closedir( DIR );

	while( scalar( @list ) )
	{
		if ( $list[ 0 ] =~ /^\./ ){ shift( @list ); next; }
		last;
	}

	return \@list;
}

sub out
{
	my ( $self ) = ( @_ );

	my $file = $self->getfilename() || $self->{ param }{ DEF };
	my $dir = '';

	if ( $file ne '' )
	{
		if ( -r $self->{ param }{ DIR } . '/' . $file . '.md')
		{
			$file .= '.md';
		} elsif ( -d $self->{ param }{ DIR } . '/' . $file )
		{
			$dir = $file;
			$file = '';
		} else
		{
			$file = ''; 
		}
	}
	$self->{ param }{ file } = $file;

	my $out;

	if ( $file ne '' )
	{
		$out = $self->outhtml();
	} elsif( $self->{ param }{ DIRLIST } && $dir ne '' )
	{
		$out = $self->dirlist( $dir );
	} else
	{
		$out = $self->error( 404 );
	}

	push( @{ $self->{ param }{ HTTP } }, "Content-Length: " . length( $out ) . "\n" );

	print @{ $self->{ param }{ HTTP } };
	print "\n";
	print $out;
}

sub error
{
	my ( $self, $code ) = ( @_ );

	$self->{ param }{ blog } = $self->{ param }{ tool } = new Tool( $self->{ param } );

	$self->{ param }{ TITLE } = 'Error - ' . $code;
	my $tmplate = new Template( $self->{ param } );
	return $tmplate->head() . $code . $tmplate->foot();
}

sub dirlist
{
	my ( $self, $dir ) = ( @_ );

	$self->{ param }{ tool } = new Tool( $self->{ param } );
	$self->{ param }{ blog } = new Blog( $self->{ param } );

	$dir = $self->getdirpath( $dir );

	my $path = $self->{ param }{ HOME } . '?f=';
	my $basedir = $self->{ param }{ DIR } . '/' . $dir;

	my @list = @{ $self->getdirlist( $dir ) };

	my $content = '<h1>' . $dir . '</h1>' . '<ul>';

	my $parent = $self->getparentdirpath( $dir );
	if ( $parent ne '' )
	{
		$content .= '<li><a href="' . $path . uri_escape_utf8( $parent ) . '">' . '..' . '</a></li>';
	}

	foreach( @list )
	{
		if ( -f $basedir . $_ && $_ =~ /(.+)\.md$/)
		{
			$_ = $1;
		}
		$content .= '<li><a href="' . $path .uri_escape_utf8( $dir . $_ ) . '">' . $_ . '</a></li>';
	}

	$content .= '</ul>';

	my $tmplate = new Template( $self->{ param } );

	return $tmplate->head() . $content . $tmplate->foot();
}

sub outhtml
{
	my ( $self ) = ( @_ );

	$self->{ param }{ tool } = new Tool( $self->{ param } );
	$self->{ param }{ blog } = new Blog( $self->{ param } );

	my $content = '';

	if ( -f $self->{ param }{ file } )
	{
		my $md = new Markdown( $self->{ param } );
		$content = ${ $md->out( $self->{ param }{ file } ) };
	}

	my $tmplate = new Template( $self->{ param } );

	return $tmplate->head() . $content . $tmplate->foot();
}

1;
