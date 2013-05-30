KEYPAIR=keypair
SSH=ssh -o StrictHostKeyChecking=no -t ubuntu@$(HOSTNAME)

define retry
  TIMEOUT=$$(date -d 81sec +%s) && while [ $$(date +%s) -lt $$TIMEOUT ]; do \
    $1 && break; \
  done
endef

all: aws
	$(call retry,(cd files && find . -type f | xargs tar c) | $(SSH) cd / \&\& sudo tar x)

	(cd .. && find untwisted -name \*.py | xargs tar c \
	  cookie/cookie \
	  cookie/Makefile \
	  mail/deliver/deliver \
	  qwer/__init__.py) | $(SSH) tar x

	$(SSH) byobu new-session \'' \
\
	  sudo DEBIAN_FRONTEND=noninteractive aptitude -DRy install \
	    apache2 \
	    libaprutil1-dbd-mysql \
	    libsasl2-modules-sql \
	    make \
	    mysql-server \
	    opendkim \
	    postfix \
	    python-mysqldb \
	    python-twisted \
\
	    libevent-pthreads-2.0-5 \
	    libgmime-2.6-0 \
	    libmhash2 \
	    libsieve2-1 && \
	  sudo dpkg -i \
	    dbmail_3.0.2-1_amd64.deb \
	    libzdb9_2.11.2-1_amd64.deb && \
\
	  $(MAKE) && \
\
	  byobu new-window "PYTHONPATH=. mail/deliver/deliver; bash" && \
\
	  $(MAKE) -C cookie && \
	  byobu new-window "PYTHONPATH=. cookie/cookie; bash"; bash'\'

aws:
	# Get latest Ubuntu AMI
	$(eval AMI=$(shell curl http://cloud-images.ubuntu.com/query/quantal/server/daily.current.txt | awk '$$5 == "ebs" && $$6 == "amd64" && $$7 == "us-east-1" && $$9 != "hvm" { print $$8 }'))

	# Run it
	$(eval INSTANCE=$(shell ec2-run-instances -k $(KEYPAIR) -t t1.micro $(AMI) | awk '/^INSTANCE/ { print $$2 }'))

	# Get hostname
	$(eval HOSTNAME=$(shell ec2-describe-instances $(INSTANCE) | awk '/^INSTANCE/ { print $$4 }'))

check:
	testify \
	  test/imap \
	  test/imapNotPassword \
	  test/receive \
	  test/smtp \
	  test/smtpNotPassword \
	  test/smtpTls \
	  test/submission \
	  test/submissionNotPassword \
	  test/submissionTls

check-dns:
	testify \
	  test/dkim \
	  test/mx \
	  test/spf \
	  test/srv

check-http:
	testify \
	  test/http \
	  test/httpNotPassword \
	  test/httpAuth

check-send: aws
	$(call retry,(cd .. && find mail untwisted -name \*.py | xargs tar c \
	  mail/test/ehlo \
	  mail/test/smtpSend \
	  mail/test/smtpTlsSend \
	  mail/test/submissionSend \
	  mail/test/submissionTlsSend \
	  qwer/__init__.py \
	  testify/__init__.py \
	  testify/testify) | $(SSH) tar x)

	$(SSH) byobu new-session \'' \
\
	  sudo aptitude -DRy install \
	    python-gnutls \
	    python-twisted && \
\
	  sudo sed -i '\'\\\'\'' #\
	    /gcry_control(GCRYCTL_SET_THREAD_CBS,/ a \
    libgnutls.gcry_check_version('\'\\\'\\\\\\\'1.2.4\\\\\\\'\\\'\'') # GNUTLS_MIN_LIBGCRYPT_VERSION'\'\\\'\'' /usr/lib/python2.7/dist-packages/gnutls/library/__init__.py && \
\
	  sudo PYTHONPATH=. testify/testify \
	    mail/test/ehlo \
	    mail/test/smtpSend \
	    mail/test/smtpTlsSend \
	    mail/test/submissionSend \
	    mail/test/submissionTlsSend; bash'\'
