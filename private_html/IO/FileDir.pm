package FileDir;

use strict;
use warnings;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { io => $param }, $package );
}

sub loadmarkdown()
{
	my ( $self, $file ) = ( @_ );

	my $title = '';
	my $md = '';

	if ( open( MD, "< " . $self->{ io }->{ param }{ DIR } . '/' . $file ) )
	{
		$title = $md = <MD>;
		while( <MD> )
		{
			$md .= $_;
		}
		close( MD );
	}

	return ( $title, \$md );
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

sub checkfiledir()
{
	my ( $self, $file ) = ( @_ );
	my $dir = '';
	if ( $file ne '' )
	{
		if ( -r $self->{ io }->{ param }{ DIR } . '/' . $file . '.md')
		{
			$file .= '.md';
		} elsif ( -d $self->{ io }->{ param }{ DIR } . '/' . $file )
		{
			$dir = $file;
			$file = '';
		} else
		{
			$file = '';
		}
	}
	return ( $file, $dir );
}

sub getdirlist()
{
	my ( $self, $dir ) = ( @_ );

	my $basedir = $self->{ io }->{ param }{ DIR } . '/' . $dir;
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

1;
