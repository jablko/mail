SSH=ssh -i $(KEYPAIR) ubuntu@$(HOSTNAME)

all:
	# us-east-1 64-bit ebs
	INSTANCE = `ec2-run-instances ami-1aad5273 -k ec2-keypair -t t1.micro | sed s/INSTANCE\s+(\S+)`

	ec2-associate-address 50.16.249.74 -i $(INSTANCE)

	HOSTNAME = `ec2-describe-instances $(INSTANCE) | sed s/INSTANCE(?:\s+(\S+)){3}`

	(cd files && find . -type f | xargs tar c) | $(SSH) cd / \&\& sudo tar x

	$(SSH) $(MAKE)

test:
	# us-east-1 64-bit ebs
	INSTANCE = `ec2-run-instances ami-1aad5273 -k ec2-keypair -t t1.micro | sed s/INSTANCE\s+(\S+)`

	HOSTNAME = `ec2-describe-instances $(INSTANCE) | sed s/INSTANCE(?:\s+(\S+)){3}`

	$(SSH) sudo aptitude -DRy install \
	  python-gnutls \
	  python-twisted
