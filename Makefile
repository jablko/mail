SSH=ssh -i $(KEYPAIR) -t ubuntu@$(HOSTNAME)

all:
	# us-east-1 64-bit ebs
	INSTANCE = `ec2-run-instances ami-1aad5273 -k ec2-keypair -t t1.micro | sed 's/INSTANCE\s+\(\S+\)/\1/p'`

	HOSTNAME = `ec2-describe-instances $(INSTANCE) | sed 's/INSTANCE(?:\s+\(\S+\)){3}/\1/p'`

	(cd files && find . -type f | xargs tar c) | $(SSH) cd / \&\& sudo tar x

	$(SSH) byobu new-session \' \
	  $(MAKE)\; \
	  bash\'

test:
	# us-east-1 64-bit ebs
	INSTANCE = `ec2-run-instances ami-1aad5273 -k ec2-keypair -t t1.micro | sed 's/INSTANCE\s+\(\S+\)/\1/p'`

	HOSTNAME = `ec2-describe-instances $(INSTANCE) | sed 's/INSTANCE(?:\s+\(\S+\)){3}/\1/p'`

	$(SSH) byobu new-session \' \
	  sudo aptitude -DRy install \
	    python-gnutls \
	    python-twisted\; \
	  bash\'
