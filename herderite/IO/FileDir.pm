package FileDir;

use strict;
use warnings;

sub new
{
	my ( $package, $io ) = @_;

	return bless ( { io => $io }, $package );
}

sub MDFoot()
{
	my ( $path ) = ( @_ );
	my $html = '';
	$html .= '<div class="mdfoot">';
	if ( $path =~ /\/([0-9]+)\/([0-9]+)\/([0-9]+)\.md$/ )
	{
		$html .= '<div>Posted:' . $1 . '/' . $2 . '/' . $3 . '</div>';
	}
	my ( $s, $m, $h, $D, $M, $Y ) = localtime( (stat( $path ))[ 9 ] );
	$html .= '<div>Update:' . ( $Y + 1900 ) . '/' . ( $M + 1 ) . '/' . $D . ' ' . $h . ':' . $m . ':' . $s . '</div>';
	$html .= '</div>';
	return $html;
}

sub LoadMarkdown()
{
	my ( $self, $file, $plugin ) = ( @_ );

	my $title = '';
	my $md = '';

	my $fh;
	$file = $self->{ io }->{ param }{ PUBDIR } . '/' . $file;
	if ( open( $fh, "< " . $file ) )
	{
		$title = <$fh>;
		$md .= $title;
		if ( $plugin )
		{
			while( <$fh> )
			{
				$md .= $plugin->MDPlugin( $_ );
			}
		} else
		{
			while( <$fh> ) { $md .= $_; }
		}
		if ( $self->{ io }->{ param }{ mddate } ){ $md .= &MDFoot( $file ); }
		close( $fh );
	}

	return ( $title, \$md );
}

sub SaveMarkdown()
{
	my ( $self, $file, $md ) = ( @_ );

	$file =~ /(.+)\/[^\/]+$/;
	my $dir = $1;
	$self->CreateRecDir( $dir );

	if ( open( MD, "> " . $self->{ io }->{ param }{ PUBDIR } . '/' . $file ) )
	{
		print MD ${ $md };
		close( MD );
	}
}

sub LoadFile()
{
	my ( $self, $file ) = ( @_ );
	my $txt = '';
	if ( open( FILE, "< $file" ) )
	{
		while( <FILE> )
		{
			$txt .= $_;
		}
		close( FILE );
	}
	return \$txt;
}

sub CreateRecDir()
{
	my ( $self, $dir ) = ( @_, '' );

	my @dir = split( /\//, $dir );
	$dir = $self->{ io }->{ param }{ PUBDIR };
	foreach ( @dir )
	{
		$dir .= '/' . $_;
		unless ( -d $dir ){ mkdir( $dir, 0705 ); }
	}
}

sub CheckFileDir()
{
	my ( $self, $file ) = ( @_ );
	my $dir = '';
	if ( $file ne '' )
	{
		if ( -d $self->{ io }->{ param }{ PUBDIR } . '/' . $file )
		{
			$dir = $file;
			$file = '';
		} elsif ( -r $self->{ io }->{ param }{ PUBDIR } . '/' . $file . '.md' || $self->{ io }->{ param }{ mode } == 1 )
		{
			$file .= '.md';
		} else
		{
			$file = '';
		}
	}
	return ( $file, $dir );
}

sub GetBlogDir()
{
	my ( $self, $dir ) = ( @_, '' );
	my @list;
	opendir( DIR, $self->{ io }->{ param }{ PUBDIR } . '/' . $self->{ io }->{ param }{ BLOG }  . '/' . $dir );
	foreach( readdir( DIR ) )
	{
		unless ( $_ =~ /^\./ ){ push( @list, $_ ); }
	}
	closedir( DIR );
	@list = sort{ $a cmp $b }( @list );
	return \@list;
}

sub GetDirList()
{
	my ( $self, $dir ) = ( @_ );

	my $basedir = $self->{ io }->{ param }{ PUBDIR } . '/' . $dir;
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
		if ( -d $basedir . '/' . $obj )
		{
			push( @dir, $obj . '/' );
		} else
		{
			if ( $obj =~ /(.+)\.md$/ ){ $obj = $1; }
			push( @file, $obj );
		}
	}

	return [ ( sort{ $a cmp $b }( @dir ) ), ( sort{ $a cmp $b }( @file ) ) ];
}

sub GetFileList()
{
	my ( $self, $dir ) = ( @_ );

	my $basedir = $self->{ io }->{ param }{ PUBDIR } . '/' . $dir . '/';
	my @file = ();
	my $dh;
	if ( opendir( $dh, $basedir ) )
	{
		foreach( readdir( $dh ) )
		{
			unless ( -f $basedir . $_  ){ next; }
			push( @file, $_ );
		}
		closedir( $dh );
	}
	return [ ( sort{ $a cmp $b }( @file ) ) ];
}

1;
