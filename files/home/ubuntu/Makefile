all:
	echo "\n\
Domain nottheoilrig.com\n\
KeyFile /home/ubuntu/default.private\n\
Selector mail" | sudo sh -c 'cat >> /etc/opendkim.conf'

	sudo a2enmod authn_dbd proxy_http

	sudo sed -i '# \
	  s/^<\/VirtualHost>/\
  DBDriver mysql\
  DBDParams dbname=dbmail,user=dbmail\
\
  <Location \/>\
\
    AuthType Basic\
    AuthName nottheoilrig\
    AuthBasicProvider dbd\
\
    # http:\/\/jdbates.blogspot.com\/2011\/01\/recently-required-little-research-to.html\
    AuthDBDUserPWQuery "SELECT ENCRYPT(passwd) FROM dbmail_users WHERE userid = %s"\
    Require valid-user\
\
    ProxyPass http:\/\/localhost:8743\/\
\
  <\/Location>\
\
<\/VirtualHost>/' /etc/apache2/sites-available/default

	sudo apache2ctl restart
