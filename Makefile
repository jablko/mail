SSH=ssh -i $(KEYPAIR) ubuntu@$(HOSTNAME)

all:
	# us-east-1 64-bit ebs
	INSTANCE = `ec2-run-instances ami-1aad5273 -k ec2-keypair -t t1.micro | sed s/INSTANCE\s+(\S+)`

	ec2-associate-address 50.16.249.74 -i $(INSTANCE)

	HOSTNAME = `ec2-describe-instances $(INSTANCE) | sed s/INSTANCE(?:\s+(\S+)){3}`

	(cd files && find . -type f | xargs tar c) | $(SSH) cd / \&\& sudo tar x

	$(SSH) sudo aptitude -DRy install \
	  apache2 \
	  dbmail-mysql \
	  libaprutil1-dbd-mysql \
	  libsasl2-modules-sql \
	  mysql-server \
	  opendkim \
	  postfix \
	  python-mysqldb \
	  python-gnutls \
	  python-twisted

	$(SSH) mysql -u root -e 'grant all on dbmail.* to dbmail@localhost'
	$(SSH) mysql -u root -e 'create database dbmail character set utf8'
	$(SSH) zcat /usr/share/doc/dbmail-mysql/examples/create_tables.mysql.gz \| mysql -u dbmail dbmail

	$(SSH) sudo sed -i '/^mydestination = / d
s/^myhostname = .*/myhostname = mail.nottheoilrig.com' /etc/postfix/main.cf
	echo '
virtual_mailbox_domains = nottheoilrig.com
virtual_transport = lmtp:localhost:8716' | $(SSH) sudo sh -c 'cat >> /etc/postfix/main.cf'

	$(SSH) sudo sed -i 'h
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
	$(SSH) sudo sed -i '/^lmtp/ a\
  -o disable_dns_lookups=yes' /etc/postfix/master.cf

	echo '
Domain nottheoilrig.com
KeyFile /home/ubuntu/default.private
Selector mail' | $(SSH) sudo sh -c 'cat >> /etc/opendkim.conf'

	$(SSH) sudo a2enmod authn_dbd proxy_http

	$(SSH) sudo sed -i 's/^<\/VirtualHost>/  DBDriver mysql\n  DBDParams dbname=dbmail,user=dbmail\n\n  <Location \/>\n\n    AuthType Basic\n    AuthName nottheoilrig\n    AuthBasicProvider dbd\n\n    # http:\/\/jdbates.blogspot.com\/2011\/01\/recently-required-little-research-to.html\n    AuthDBDUserPWQuery "SELECT ENCRYPT(passwd) FROM dbmail_users WHERE userid = %s"\n    Require valid-user\n\n    ProxyPass http:\/\/localhost:8743\/\n\n  <\/Location>\n\n<\/VirtualHost>/' /etc/apache2/sites-available/default

test:
	# us-east-1 64-bit ebs
	INSTANCE = `ec2-run-instances ami-1aad5273 -k ec2-keypair -t t1.micro | sed s/INSTANCE\s+(\S+)`

	HOSTNAME = `ec2-describe-instances $(INSTANCE) | sed s/INSTANCE(?:\s+(\S+)){3}`

	$(SSH) sudo aptitude -DRy install \
	  python-gnutls \
	  python-twisted
