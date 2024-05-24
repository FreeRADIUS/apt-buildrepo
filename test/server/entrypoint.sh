#! /bin/sh

mkdir -p /srv/repository/pool
cp /data/tmp/*.deb /srv/repository/pool

/usr/local/bin/apt-buildrepo \
	-O "My Organisation Name" \
	-L "An optional label" \
	-c "buster" \
	-s "buster" \
	-p "pool" \
	-r 'test@example.com' \
	-P "/data/tmp/passphrase" \
	-k "/data/tmp/secring.gpg" \
	/srv/repository

nginx -g 'daemon off;'
