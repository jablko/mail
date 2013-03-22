all:
	mysql -u root -e 'grant all on dbmail.* to dbmail@localhost'
	mysql -u root -e 'create database dbmail character set utf8'
	zcat /usr/share/doc/dbmail-mysql/examples/create_tables.mysql.gz | mysql -u dbmail dbmail

	sudo sed -i '
	  /^mydestination = / d
	  s/^myhostname = .*/myhostname = mail.nottheoilrig.com' /etc/postfix/main.cf
	echo "\n\
virtual_mailbox_domains = nottheoilrig.com\n\
virtual_transport = lmtp:localhost:8716" | sudo sh -c 'cat >> /etc/postfix/main.cf'

	sudo sed -i '
	  h
	  s/^smtp      inet  n       -       -/smtp      inet  n       -       n/
	  T
	  p
	  i\
  -o smtpd_proxy_filter=localhost:1438\
  -o smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination\
  -o smtpd_sasl_auth_enable=yes
	  s/^smtp/submission/
	  p
	  i\
  -o smtpd_proxy_filter=localhost:1438\
  -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject\
  -o smtpd_sasl_auth_enable=yes
	  g
	  s/^smtp/localhost:1894/
	  a\
  -o smtpd_authorized_xforward_hosts=localhost\
  -o smtpd_milters=inet:localhost:8891' /etc/postfix/master.cf
	sudo sed -i '
	  /^lmtp/ a\
  -o disable_dns_lookups=yes' /etc/postfix/master.cf

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
