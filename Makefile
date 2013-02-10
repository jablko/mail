KEYPAIR=keypair
SSH=ssh -t ubuntu@$(HOSTNAME)

all:
	# us-east-1 64-bit ebs
	$(eval INSTANCE=$(shell ec2-run-instances ami-1aad5273 -k $(KEYPAIR) -t t1.micro | awk '/^INSTANCE/ { print $$2 }'))

	$(eval HOSTNAME=$(shell ec2-describe-instances $(INSTANCE) | awk '/^INSTANCE/ { print $$4 }'))

	(cd files && find . -type f | xargs tar c) | $(SSH) cd / \&\& sudo tar x

	$(SSH) byobu new-session \' \
	  $(MAKE)\; \
	  bash\'

test:
	# us-east-1 64-bit ebs
	$(eval INSTANCE=$(shell ec2-run-instances ami-1aad5273 -k $(KEYPAIR) -t t1.micro | awk '/^INSTANCE/ { print $$2 }'))

	$(eval HOSTNAME=$(shell ec2-describe-instances $(INSTANCE) | awk '/^INSTANCE/ { print $$4 }'))

	$(SSH) byobu new-session \' \
	  sudo aptitude -DRy install \
	    python-gnutls \
	    python-twisted\; \
	  bash\'
