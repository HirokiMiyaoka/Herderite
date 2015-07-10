package SQLiteDB;

use strict;
use warnings;

use DBI;

sub new
{
	my ( $package, $io ) = @_;

	return bless ( { io => $io }, $package );
}

sub MDFoot()
{
	my ( $path ) = ( @_ );
	my $html = '';

	# TODO: DB inout.

	return $html;
}

sub LoadMarkdown()
{
	my ( $self, $file, $plugin ) = ( @_ );

	my $title = '';
	my $md = '';

	# TODO: DB inout.

	return ( $title, \$md );
}

sub SaveMarkdown()
{
	my ( $self, $file, $md ) = ( @_ );

	# TODO: DB inout.
}

sub LoadFile()
{
	my ( $self, $file ) = ( @_ );
	my $txt = '';

	# TODO: DB inout.

	return \$txt;
}

sub CreateRecDir()
{
	my ( $self, $dir ) = ( @_, '' );

	# TODO: DB inout.
}

sub CheckFileDir()
{
	my ( $self, $file ) = ( @_ );
	my $dir = '';

	# TODO: DB inout.

	return ( $file, $dir );
}

sub GetBlogDir()
{
	my ( $self, $dir ) = ( @_, '' );

	# TODO: DB inout.

	return [];
}

sub GetDirList()
{
	my ( $self, $dir ) = ( @_ );

	# TODO: DB inout.

	return [];
}

sub GetFileList()
{
	my ( $self, $dir ) = ( @_ );

	# TODO: DB inout.

	return [];
}

sub GetCategoryList()
{
	my ( $self ) = ( @_ );

	my $dbf = $self->{ io }->{ param }{ DBDIR } . '/' . 'category.db';
	my @catelist;
	my $cate;

	my $dbh = DBI->connect( "dbi:SQLite:dbname=$dbf" );
	my $sth = $dbh->prepare( "SELECT name FROM sqlite_master WHERE type = 'table';" );
	$sth->execute;
	while( ( $cate ) = $sth->fetchrow_array() ) { push( @catelist, $cate ); }
	$sth->finish;
	$dbh->disconnect;

	return \@catelist;
}

sub GetCategoryFileList()
{
	my ( $self, $cate ) = ( @_ );

	$cate = &Cate( $cate );

	if ( $cate eq ''){ return []; }

	my @list;
	my $blog;

	my $dbf = $self->{ io }->{ param }{ DBDIR } . '/' . 'category.db';

	my $dbh = DBI->connect( "dbi:SQLite:dbname=$dbf" );
	my $sth = $dbh->prepare( "SELECT * FROM $cate;" );
	$sth->execute;
	while( ( $blog ) = $sth->fetchrow_array() ) { push( @list, $blog ); }
	$sth->finish;
	$dbh->disconnect;

	return \@list;
}

sub SetCategory()
{
	my ( $self, $file, @cate ) = ( @_ );

	$file =~ s/^\.\///;

	my @list = @{ $self->GetCategoryList() };

	my $dbf = $self->{ io }->{ param }{ DBDIR } . '/' . 'category.db';
	my $dbh = DBI->connect( "dbi:SQLite:dbname=$dbf" );

	# Delete
	foreach ( @list ) { $dbh->do( "DELETE FROM $_ WHERE file = '$file';" ); }

	my $cate;
	my $ext;
	foreach( @cate )
	{
		$cate = &Cate( $_ );
		if ( $cate eq '' ){ next; }
		( $ext ) = ( $dbh->selectrow_array( "SELECT name FROM sqlite_master WHERE name = '$cate';" ), '' );
		if ( $ext eq '' ){ $dbh->do( "CREATE TABLE $cate ( file UNIQUE );" ); }
		$dbh->do( "INSERT OR IGNORE INTO $cate ( file ) values ( '$file' );" );
	}

	$dbh->disconnect;
}

sub Cate()
{
	my ( $cate ) = ( @_, '' );
	$cate =~ s/[^\w\d]//g;
	return $cate;
}

1;
