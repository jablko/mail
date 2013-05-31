all:
	# DBMail
	mysql -u root -e 'GRANT ALL ON dbmail.* TO dbmail@localhost'
	mysqladmin -u root create dbmail
	zcat /usr/share/doc/dbmail/examples/create_tables.mysql.gz | mysql -u dbmail dbmail
	sudo sed -i ' #\
	  s/^\(driver *=\).*/\1 mysql/ #\
	  s/^\(authdriver *=\).*/\1 sql/' /etc/dbmail/dbmail.conf
	sudo sed -i ' #\
	  s/^#START_IMAPD=true/START_IMAPD=true/ #\
	  s/^#START_LMTPD=true/START_LMTPD=true/' /etc/default/dbmail
	sudo invoke-rc.d dbmail restart

	# Postfix
	sudo sed -i ' #\
	  s/^myhostname =.*/myhostname = mail.nottheoilrig.com/ #\
	  $$ a \
\
virtual_mailbox_domains = nottheoilrig.com\
virtual_transport = lmtp:localhost:8716' /etc/postfix/main.cf
	echo ' #\
	  s/^smtp      inet  n       -       -/smtp      inet  n       -       n/ #\
	  T #\
	  p #\
	  i \
  -o smtpd_proxy_filter=:1438\
  -o smtpd_sasl_auth_enable=yes\n #\
	  s/^smtp/submission/ #\
	  p #\
	  i \
  -o smtpd_proxy_filter=:1438\
  -o smtpd_sasl_auth_enable=yes\n #\
	  s/^submission/localhost:1894/ #\
	  a \
  -o smtpd_authorized_xforward_hosts=localhost\
  -o smtpd_milters=unix:/var/run/opendkim/opendkim.sock' | sudo sed -f - -i /etc/postfix/master.cf
	sudo postfix reload

	# OpenDKIM
	echo "\n\
Domain nottheoilrig.com\n\
KeyFile /run/opendkim/default.private\n\
Selector mail" | sudo sh -c 'cat >> /etc/opendkim.conf'
	sudo invoke-rc.d opendkim restart
	sudo adduser postfix opendkim

	# Apache
	sudo a2enmod authn_dbd proxy_http
	sudo apache2ctl restart
