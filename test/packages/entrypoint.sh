#! /bin/sh

UID=`stat -c %u /data`
GID=`stat -c %g /data`

OUTDIR=/data/tmp
TMPDIR=/tmp/files

rm -rf "$TMPDIR"

if [ -r "$OUTDIR/passphrase" \
	-a -r "$OUTDIR/secring.gpg" \
	-a -r "$OUTDIR/test@example.com.asc" ]; then

	echo "Skipping GPG key generation - already exists"

else

	echo "Generating test GPG key"

	rm -rf /root/.gnupg

	PASS="$TMPDIR/passphrase"

	mkdir -p "$TMPDIR"

	dd if=/dev/urandom bs=12 count=1 2>/dev/null | base64 > "$PASS"

	gpg --batch \
		--passphrase-file "$PASS" \
		--quick-generate-key 'test@example.com'

	gpg --batch \
		--pinentry-mode=loopback \
		--passphrase-file "$PASS" \
		--export-secret-keys \
		> "$TMPDIR/secring.gpg"

	gpg --batch \
		--armor \
		--export \
		> "$TMPDIR/test@example.com.asc"

	install -o "$UID" -g "$GID" -m 0755 -d "$OUTDIR"
	install -o "$UID" -g "$GID" -m 0600 "$PASS" "$OUTDIR/passphrase"
	install -o "$UID" -g "$GID" -m 0600 "$TMPDIR/secring.gpg" "$OUTDIR/secring.gpg"
	install -o "$UID" -g "$GID" -m 0644 "$TMPDIR/test@example.com.asc" "$OUTDIR/test@example.com.asc"

fi


ARCH=`dpkg --print-architecture`
PKGNAME="repo-test-pkg_1.0_$ARCH.deb"

if [ -r "$OUTDIR/$PKGNAME" ]; then

	echo "Skipping test package build - already exists"

else

	echo "Generating test .deb package"

	PKGDIR="$TMPDIR/pkg"
	mkdir "$PKGDIR"

	mkdir -p "$PKGDIR/usr/bin"
	printf "#! /bin/sh\necho 'Test package downloaded and installed OK'\n" > "$PKGDIR/usr/bin/pkg-test-script"
	chmod 755 "$PKGDIR/usr/bin/pkg-test-script"


	mkdir "$PKGDIR/DEBIAN"
	cat <<-EOF >"$PKGDIR/DEBIAN/control"
	Package: repo-test-pkg
	Version: 1.0
	Section: utils
	Priority: optional
	Architecture: $ARCH
	Maintainer: Nobody <nobody@example.com>
	Description: Test package for apt-buildrepo
	EOF

	dpkg-deb --build "$PKGDIR" "$TMPDIR"

	echo "Built $PKGNAME"

	install -o "$UID" -g "$GID" -m 0644 "$TMPDIR/$PKGNAME" "$OUTDIR/$PKGNAME"

fi

