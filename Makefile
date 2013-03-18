KEYPAIR=keypair
SSH=ssh -o StrictHostKeyChecking=no -t ubuntu@$(HOSTNAME)

all:
	$(eval AMI=$(shell curl http://cloud-images.ubuntu.com/query/quantal/server/daily.current.txt | awk '$$5 == "ebs" && $$6 == "amd64" && $$7 == "us-east-1" && $$9 != "hvm" { print $$8 }'))

	$(eval INSTANCE=$(shell ec2-run-instances -k $(KEYPAIR) -t t1.micro $(AMI) | awk '/^INSTANCE/ { print $$2 }'))

	$(eval HOSTNAME=$(shell ec2-describe-instances $(INSTANCE) | awk '/^INSTANCE/ { print $$4 }'))

	TIMEOUT=$$(date -d 27sec +%s) && while [ $$(date +%s) -lt $$TIMEOUT ]; do \
	  (cd files && find . -type f | xargs tar c) | $(SSH) cd / \&\& sudo tar x && break; \
	done

	$(SSH) byobu new-session \' \
	  sudo DEBIAN_FRONTEND=noninteractive aptitude -DRy install \
	    apache2 \
	    dbmail-mysql \
	    libaprutil1-dbd-mysql \
	    libsasl2-modules-sql \
	    make \
	    mysql-server \
	    opendkim \
	    postfix \
	    python-mysqldb \
	    python-twisted \&\& \
	  $(MAKE)\; \
	  bash\'

test:
	testify test/send test/sendTls test/submit test/submitTls

test/dns:
	testify test/dkim test/mx test/spf test/srv

test/relay:
	$(eval AMI=$(shell curl http://cloud-images.ubuntu.com/query/quantal/server/daily.current.txt | awk '$$5 == "ebs" && $$6 == "amd64" && $$7 == "us-east-1" && $$9 != "hvm" { print $$8 }'))

	$(eval INSTANCE=$(shell ec2-run-instances -k $(KEYPAIR) -t t1.micro $(AMI) | awk '/^INSTANCE/ { print $$2 }'))

	$(eval HOSTNAME=$(shell ec2-describe-instances $(INSTANCE) | awk '/^INSTANCE/ { print $$4 }'))

	$(SSH) byobu new-session \' \
	  sudo aptitude -DRy install \
	    python-gnutls \
	    python-twisted\; \
	  bash\'

.PHONY: test
