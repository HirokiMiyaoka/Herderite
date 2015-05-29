# Herderite

## Use module.

```
cpan Text::Markdown
cpan Text::Markdown::Hoedown
cpan URI::Escape
```

## Install example

```
/var/www/herderite/
/var/www/public_html/  ... http server docroot
/var/www/private_html/ ... http server private docroot
```

```
chmod 705 public_html/index.cgi
chmod 705 private_html/*.cgi
```

```
vim /etc/httpd/conf.d/vhosts.conf
NameVirtualHost *:80

AddHandler cgi-script .cgi

<VirtualHost *:80>
  ServerName example.com
  DocumentRoot /var/www/public_html
</VirtualHost>

<VirtualHost *:80>
  ServerName private.example.com
  DocumentRoot /var/www/private_html
  HostNameLookups off
</VirtualHost>
<Directory /var/www/private_html>
  Options FollowSymLinks ExecCGI
  AllowOverride All
  Order allow,deny
  Allow from all
  AuthType Digest
  AuthName "Privste"
  AuthUserFile /var/www/etc/.htdigest
  Require valid-user
</Directory>
```

## Setting

Please edit herderite/conf.pm (and herderite/Front/Template.pm).

Cannot overwrite conf.pm when update.

```
chmod 400 herderite/conf.pm
```