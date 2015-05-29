package FileDir;

use strict;
use warnings;

sub new
{
	my ( $package, $io ) = @_;

	return bless ( { io => $io }, $package );
}

sub loadmarkdown()
{
	my ( $self, $file, $plugin ) = ( @_ );

	my $title = '';
	my $md = '';

	my $fh;
	if ( open( $fh, "< " . $self->{ io }->{ param }{ PUBDIR } . '/' . $file ) )
	{
		$title = $md = <$fh>;
		if ( $plugin )
		{
			while( <$fh> )
			{
				$md .= $plugin->mdplugin( $_ );
			}
		} else
		{
			while( <$fh> ) { $md .= $_; }
		}
		close( $fh );
	}

	return ( $title, \$md );
}

sub savemarkdown()
{
	my ( $self, $file, $md ) = ( @_ );

	$file =~ /(.+)\/[^\/]+$/;
	my $dir = $1;
	$self->createrecdir( $dir );

	if ( open( MD, "> " . $self->{ io }->{ param }{ PUBDIR } . '/' . $file ) )
	{
		print MD ${ $md };
		close( MD );
	}
}

sub loadfile()
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

sub createrecdir()
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

sub checkfiledir()
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

sub getblogdir()
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

sub getdirlist()
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

sub getfilelist()
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
