package AdFront;

use strict;
use warnings;

use URI::Escape;

use Front;
our @ISA = qw( Front );

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub Init()
{
	my ( $self ) = ( @_ );

    $self->SUPER::Init();
	$self->{ param }{ mddate } = 0;

	unless ( exists( $self->{ io }->{ post }{ text } ) ){ $self->{ io }->{ post }{ text } = ''; }

	my $uri = $ENV{ REQUEST_URI } || '';
	$uri =~ /([^\/]+)(?:\?.+)$/;
	$self->{ param }{ script } = $1 || './';

	$self->{ io }->WriteMode();
}

sub Error
{
	my ( $self, $code ) = ( @_ );

	if ( $code != 404 )
	{
		$self->{ param }{ blog } = $self->{ plugin }{ tool };
		$self->{ param }{ TITLE } = 'Error - ' . $code;
		my $tmplate = new Template( $self->{ param }, $self->{ plugin } );
		return \( $tmplate->Head() . $code . $tmplate->Foot() );
	}

	$self->{ param }{ file } = $self->{ io }->{ get }{ f } . '.md';
	return $self->OutHtml();
}

sub DirList
{
	my ( $self, $dir ) = ( @_ );

	$self->{ plugin }{ blog } = new Blog( $self->{ param }, $self->{ io } );

	$dir = $self->{ io }->GetDirPath( $dir );

	my $path = $self->{ param }{ HOME } . '?f=';
	my $basedir = $self->{ param }{ PUBDIR } . '/' . $dir;

	if ( exists( $self->{ io }->{ post }{ d } ) && $self->{ io }->{ post }{ d } ne '' )
	{
		mkdir( $basedir . $self->{ io }->{ post }{ d }, 0705 ); #TODO: moev FileIO
	}

	my @list = @{ $self->{ io }->GetDirList( $dir ) };

	my $content = '<h1>' . $dir . '</h1><ul>';

	my $parent = $self->{ io }->GetParentDirPath( $dir );
	if ( $parent ne '' || $dir ne './' )
	{
		$content .= '<li><a href="' . $path . ( $parent eq '' ? '.' : uri_escape_utf8( $parent )) . '">' . '../' . '</a></li>';
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

	my $tmplate = new Template( $self->{ param }, $self->{ plugin } );

	my $newblog = $self->{ param }{ BLOG };
	if ( $dir =~ /^(\.\/){0,1}$newblog\/$/ )
	{
		my ( @t ) = localtime( time() ); #TODO: param->time.
		$newblog = '<form style="float:right;margin:5px;" action="' .
		$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
		'" method="get"><input type="hidden" name="b" value="' .
		sprintf( '%4d%02d%02d', $t[ 5 ] + 1900, $t[ 4 ] + 1, $t[ 3 ] ) .
		'" /><input type="submit" value="Blog post" /></form>';
	} else{ $newblog = ''; }

	return \( $tmplate->Head() .
	'<div style="height:1em;">' .
	$newblog .
	'<form style="float:right;margin:5px;" action="' .
	$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
	'" method="post"><input type="text" name="d" /><input type="submit" value="Create dir" /></form>' .
	'<form style="float:right;margin:5px;" action="' .
	$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
	'" method="get"><input type="text" name="f" /><input type="submit" value="Create page" /></form></div>' .
	$content . $tmplate->Foot() );
}

sub OutHtml
{
	my ( $self ) = ( @_ );

	$self->{ plugin }{ blog } = new Blog( $self->{ param }, $self->{ io } );
	my $md = new Markdown( $self->{ param }, $self->{ io } );

	my $content = '';

	my $mdtxt = \'';
	my $title = "";

	if ( $self->{ io }->{ post }{ text } ne '' )
	{
		( $title ) = split( /\n/, $self->{ io }->{ post }{ text }, 2 );
		$content = ${ $md->OutInMem( \$self->{ io }->{ post }{ text }, $self->{ plugin }{ management } ) };

		if ( exists( $self->{ io }->{ post }{ post } ) )
		{
			$self->{ io }->SaveMarkdown( $self->{ param }{ file }, \$self->{ io }->{ post }{ text } );
			# TODO: write check.
			my $tmp = $self->{ io }->{ post }{ text };
			$mdtxt = \$tmp;
			$self->{ io }->{ post }{ text } = '';
			$self->{ param }{ redirect } = $ENV{ REQUEST_URI };
			return \( '' );
		}

	} else
	{
		( $title, $mdtxt ) = $self->{ io }->LoadMarkdown( $self->{ param }{ file } );
		$content = ${ $md->OutInMem( $mdtxt, $self->{ plugin }{ management } ) };
	}

	$title =~ s/^\#+ //;
	$title =~ s/[\r\n]//g;
	$title =~ s/\<.+\>(.+)\<\/.+\>/$1/g;
	#$title =~ s/([^\\s]+)/$1/;
	if ( $title ne '' ){ $title .= ' - '; }

	$self->{ param }{ TITLE } = $title . $self->{ param }{ TITLE };

	my $tmplate = new Template( $self->{ param }, $self->{ plugin } );

	$self->{ param }{ CSS } .= 'div#dragupload{width:70%;height:1em;text-align:center;padding:20px;margin:auto;background-color:rgba(127,127,127,0.5);}';
	$self->{ param }{ JS } .= '
function Load(){
var script = document.createElement( "script" );
script.type = "text/javascript";
script.src = "upload.js";
var firstScript = document.getElementsByTagName( "script" )[ 0 ];
firstScript.parentNode.insertBefore( script, firstScript );
}
Load();
window.onload = function () {Init()};';

	return \( $tmplate->Head() . $self->Form( \($self->{ io }->{ post }{ text } || ${ $mdtxt } ) ) . $content . $tmplate->Foot() );
}

sub Form()
{
	my ( $self, $md ) = ( @_ );
	if ( ${ $md } eq '' ) { ${ $md } = "# Title\n\n{{category}}"; }
	return '<form style="margin:0.5em 0px;" required="required" action="' .
	$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
	'" method="post"><textarea style="width:98%;height:200px;margin:10px auto;display:block;" name="text" autofocus="autofocus">' . ${ $md } .
	'</textarea>' .
	'<input type="submit" name="preview" value="Preview" />' .
	($self->{ io }->{ post }{ text } eq '' ? '' : '<input type="submit" name="post" value="Post" />') .
	'</form>' . ${ $self->UploadForm() } .
	'<div id="dragupload">Drag upload</div>' .
	'<hr />';
}

sub UploadForm()
{
	my ( $self ) = ( @_ );
	my ( $path, $f ) = $self->{ io }->GetCurrentDir();
	my $base = $self->{ param }{ UPLOAD } . '/';
	if ( $f ne $self->{ param }{ DEF } )
	{
		$path .= '/' . $f . '/';
	}

	my @files = @{ $self->{ io }->GetFileList( $base . $path ) };

	my $html = '';

	$html = '<table id="filelist"><tr><td>File</td><td>Del</td></tr>';
	my $pubpath = $self->{ param }{ ADDRESS } . '/' . $base . $path;
	foreach ( @files )
	{
		$html .= '<tr><td><a href="' . $pubpath . $_ . '" target="_blank">' . $_ . '</a></td><td>' .
			'<a href="./file.cgi?mode=remove&path=' . $path . $_ . '">Del</a></td></tr>';
	}
	$html .= '</table>';

	$html .= '<form action="./uploader.cgi" method="post" enctype="multipart/form-data">';
	$html .= '<table class="upload"><tr><td><input type="file" name="upfile" class="upfile" /></td><td>';
	$html .= '<input type="hidden" name="path" value="' . $path . '" id="path" />';
	$html .= '<input type="hidden" name="ref" value="' . $self->{ param }{ PRIVATE } . $ENV{ REQUEST_URI } . '" />';
	$html .= '<input type="submit" name="send" value="Uplaod" class="submit" /></td></tr></table></form>';

	return \$html;
}

sub Redirect()
{
	my ( $self, $path ) = ( @_ );
	print 'Location: ' . ( $self->{ param }{ PRIVATE } . $path ) . "\n\n";
	exit( 0 );
}

1;
