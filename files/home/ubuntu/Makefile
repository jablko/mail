all:: dbmail
dbmail:
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

all:: postfix
postfix:
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

all:: opendkim
opendkim:
	echo "\n\
Domain nottheoilrig.com\n\
KeyFile /run/opendkim/default.private\n\
Selector mail" | sudo sh -c 'cat >> /etc/opendkim.conf'
	sudo invoke-rc.d opendkim restart
	sudo adduser postfix opendkim

all:: apache
apache:
	sudo a2enmod authn_dbd proxy_http
	sudo apache2ctl restart

all:: cacti
cacti:
	wget http://cacti.net/downloads/cacti-0.8.8a.tar.gz
	sudo mkdir /var/www/cacti
	(cd /var/www/cacti && \
	  sudo tar xz --no-same-owner --strip-components 1 < ~/cacti-0.8.8a.tar.gz && \
	  curl "http://anonscm.debian.org/gitweb/?p=pkg-cacti/cacti.git;a=blob_plain;f=debian/patches/fix_php_strict_warning_in_ping.patch" | sudo patch -p1 && \
	  curl "http://anonscm.debian.org/gitweb/?p=pkg-cacti/cacti.git;a=blob_plain;f=debian/patches/poller_cache_rebuild_on_install.patch" | sudo patch -p1)
	sudo chown www-data \
	  /var/www/cacti/log/cacti.log \
	  /var/www/cacti/rra
	mysql -u root -e 'GRANT ALL ON cacti.* TO cacti@localhost'
	mysqladmin -u root create cacti
	mysql -u cacti cacti < /var/www/cacti/cacti.sql
	sudo sed -i ' #\
	  s/^$$database_username = "cactiuser";/$$database_username = "cacti";/ #\
	  s/^$$database_password = "cactiuser";/$$database_password = "";/' /var/www/cacti/include/config.php
