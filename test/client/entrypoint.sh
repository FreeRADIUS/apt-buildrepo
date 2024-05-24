#! /bin/sh

rm -f /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources

export DEBIAN_FRONTEND=noninteractive

cp /data/client/test.list /etc/apt/sources.list.d/test.list
cp /data/tmp/test@example.com.asc /etc/apt/keyrings/test@example.com.asc

apt-get update
apt-get install -y repo-test-pkg

/usr/bin/pkg-test-script
