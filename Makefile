KEYPAIR=keypair
SSH=ssh -t ubuntu@$(HOSTNAME)

all:
	$(eval AMI=$(shell curl http://cloud-images.ubuntu.com/query/quantal/server/daily.current.txt | awk '$$5 == "ebs" && $$6 == "amd64" && $$7 == "us-east-1" && $$9 != "hvm" { print $$8 }'))

	$(eval INSTANCE=$(shell ec2-run-instances -k $(KEYPAIR) -t t1.micro $(AMI) | awk '/^INSTANCE/ { print $$2 }'))

	$(eval HOSTNAME=$(shell ec2-describe-instances $(INSTANCE) | awk '/^INSTANCE/ { print $$4 }'))

	(cd files && find . -type f | xargs tar c) | $(SSH) cd / \&\& sudo tar x

	$(SSH) byobu new-session \' \
	  $(MAKE)\; \
	  bash\'

test:
	$(eval AMI=$(shell curl http://cloud-images.ubuntu.com/query/quantal/server/daily.current.txt | awk '$$5 == "ebs" && $$6 == "amd64" && $$7 == "us-east-1" && $$9 != "hvm" { print $$8 }'))

	$(eval INSTANCE=$(shell ec2-run-instances -k $(KEYPAIR) -t t1.micro $(AMI) | awk '/^INSTANCE/ { print $$2 }'))

	$(eval HOSTNAME=$(shell ec2-describe-instances $(INSTANCE) | awk '/^INSTANCE/ { print $$4 }'))

	$(SSH) byobu new-session \' \
	  sudo aptitude -DRy install \
	    python-gnutls \
	    python-twisted\; \
	  bash\'
