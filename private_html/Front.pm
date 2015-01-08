package Front;

use strict;
use warnings;

use URI::Escape;

use HerderiteIO;
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

sub init
{
	my ( $self ) = ( @_ );
	$self->{ io } = new HerderiteIO( $self->{ param } );
	$self->getdevice();
	$self->{ io }->decode();
}

sub getfilename()
{
	my ( $self ) = ( @_ );
	my $file = $self->{ io }->{ get }{ f };

	if ( $self->{ io }->{ get }{ b } ne '' )
	{
		my ( $y, $m, $d ) = ( '0000', '00', '00' );
		if ( $self->{ io }->{ get }{ b } =~ /([0-9]{4})([0-9]{2})([0-9]{2})/ )
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
	return $1 || '';
}

sub getdirlist()
{
	my ( $self, $dir ) = ( @_ );

	my $basedir = $self->{ param }{ DIR } . '/' . $dir;
	opendir( DIR, $basedir );
	my @list = readdir( DIR );
	closedir( DIR );

	my @dir;
	my @file;
	my $obj;
	while( scalar( @list ) )
	{
		$obj = shift( @list );
		if ( $obj =~ /^\./ ){ next; }
		if ( -f $basedir . $obj )
		{
			if ( $obj =~ /(.+)\.md$/ ){ $obj = $1; }
			push( @file, $obj );
		} else
		{
			push( @dir, $obj . '/' );
		}
	}

	return [ sort{ $a cmp $b }( @dir ), sort{ $a cmp $b }( @file ) ];
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
	if ( $parent ne '' || $dir ne './' )
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
