package conf;
sub param{return {
DL	=> 1,
DIR	=> '.',
HOME=> '',
BLOG=> 'blog',
HTTP=> ["Content-Type: text/html\n"],
%{$_[0]}};}
1;
