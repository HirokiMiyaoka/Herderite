package HerderiteIO;

use strict;
use warnings;

use IO::FileDir;
use IO::SQLiteDB;

sub new
{
	my ( $package, $param ) = @_;

	my $obj =  bless ( { param => $param }, $package );

	$obj->ReadMode();
	$obj->{ filedir } = new FileDir( $obj );
	$obj->{ sqldb } = new SQLiteDB( $obj );

	return $obj;
}

sub GetDevice
{
	return $ENV{ 'HTTP_USER_AGENT' } || '';
}

sub Decode()
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

sub WriteMode()
{
	my ( $self ) = ( @_ );
	$self->{ param }{ mode } = 1;
}

sub ReadMode()
{
	my ( $self ) = ( @_ );
	$self->{ param }{ mode } = 0;
}

sub LoadMarkdown()
{
	my ( $self, $file, $plugin ) = ( @_ );
	return $self->{ filedir }->LoadMarkdown( $file, $plugin );
}

sub SaveMarkdown()
{
	my ( $self, $file, $md ) = ( @_ );

	if ( ${ $md } =~ /\{\{category(?:\s+)(.+)\}\}/ )
	{
		$self->SetCategory( $file, split( ',', $1 ) );
	} else
	{
		$self->SetCategory( $file );
	}

	return $self->{ filedir }->SaveMarkdown( $file, $md );
}

sub LoadFile()
{
	my ( $self, $file ) = ( @_ );
	return $self->{ filedir }->LoadFile();
}

sub GetCurrentDir()
{
	my ( $self ) = ( @_ );
	my @e = split( /\//, $self->GetFileName() );
	my $f = pop( @e );
	return ( join( '/', @e ), $f );
}

sub GetFileName()
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
		$file = $self->{ param }{ DEF };
	}

	return $file || $self->{ param }{ DEF };
}

sub CheckFileDir()
{
	my ( $self, $file ) = ( @_ );
	return $self->{ filedir }->CheckFileDir( $file );
}

sub GetDirPath()
{
	my ( $self, $dir ) = ( @_ );
	$dir =~ s/\/{2,}/\//g;
	unless ( $dir =~ /\/$/ ){ $dir .= '/';}
	return $dir;
}

sub GetParentDirPath()
{
	my ( $self, $dir ) = ( @_ );
	$dir =~ /^(.+\/)(?:[^\/]+\/)$/;
	return $1 || '';
}

sub GetBlogDir()
{
	my ( $self, $dir ) = ( @_, '' );
	return $self->{ filedir }->GetBlogDir( $dir );
}

sub GetDirList()
{
	my ( $self, $dir ) = ( @_ );
	return $self->{ filedir }->GetDirList( $dir );
}

sub GetFileList()
{
	my ( $self, $dir ) = ( @_ );
	return $self->{ filedir }->GetFileList( $dir );
}

sub GetCategoryList()
{
	my ( $self ) = ( @_ );
	return $self->{ sqldb }->GetCategoryList();
}

sub GetCategoryFileList()
{
	my ( $self, $cate ) = ( @_ );
	return $self->{ sqldb }->GetCategoryFileList( $cate );
}

sub SetCategory()
{
	my ( $self, $file, @cate ) = ( @_ );
	return $self->{ sqldb }->SetCategory( $file, @cate );
}

sub SetBlogCategory()
{
	my ( $self, $blog, @cate ) = ( @_ );
	$blog =~ /([0-9]{4})([0-9]{2})([0-9]{2})/;
	my $file = $self->{ param }{ BLOG } . '/' . $1 . '/' . $2 . '/' . $3 . 'md';
	return $self->SetCategory( $file, @cate );
}

1;
