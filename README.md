apt-buildrepo
=============

This is a relatively simple utility to create a Debian APT package repository.


Why another utility, there are so many around already?
------------------------------------------------------

We needed to generate repositories with the following criteria:

- Easy to create from local files (like the RPM `createrepo` utility)

- Can handle multiple versions of the same package

- No large complexity, run once and be done with it

- Can be served over the web for apt (unlike `dpkg-scanpackages`)

We used to publish packages with `reprepro`, but that can only handle one
version of each package, meaning the old packages are removed when a new one is
made available. People (including ourselves) didn't like this because they
couldn't easily downgrade if there were issues. We like to keep all published
packages available.

Since then we moved to `aptly`, which can keep multiple package versions in the
repository. But it has fairly complex publishing requirements involving a set
of source packages, a database of packages, needing to create a "snapshot" and
then publishing that snapshot (which copies all the packages, so double the
disk space). Then removing packages from the repository (devel packages aren't
kept for ever) means having to work out all the individual packages and
republishing the snapshot. In short, it's pretty complex.

Both these utilities are good, just they don't quite fit our needs.

With `apt-buildrepo`, you create a top-level directory, copy packages into it,
and run the utility. That's it. The directory can then be served over HTTP(S)
and job done. Because the package directories are not fixed under any
structure, they can e.g. be created by date, which means older packages can be
removed simply be removing all directories older than a particular date and
re-running the same `apt-buildrepo` command.


Design decisions
----------------

This is intended to be simple. There's no database, no configuration files and
nothing but a single script to run. Most heavy lifting (e.g. calculating
checksums) is done by running external commands. Only one repo component
("main") is currently supported, again to keep things simple.


Dependencies
------------

Several standard utilities are required:

- `md5sum`, `sha1sum`, `sha256sum`, `sha512sum`, for file checksums
- `dpkg-deb` to read package information
- `gnupg`, for file signing


Usage
-----

The script expects the filesystem to be partially ready before operation. It
only creates the new repo files and does not remove old ones. No packages are
copied in to place so these need to be added first (which is the whole point of
this script anyway!)

Create the repo root level directory:

    mkdir repository

Make a directory to store packages. This should be under the top level
directory. It's normally called "pool", but could be called anything:

    mkdir repository/pool

Make some other directories (if wanted) and copy in some packages:

    mkdir respository/pool/release1
    cp /location1/*.deb respository/pool/release1/

    mkdir respository/pool/release2
    cp /location2/*.deb respository/pool/release2/

Ensure you have the GPG secret keyring (`secring.gpg`) and a file containing the
passphrase available, or otherwise ensure that the gpg agent is running and the
keyring is already available in the GPG standard keyring. To build the
repository with the signing files:

    /usr/local/bin/apt-buildrepo \
        -O "My Organisation Name" \
        -L "An optional label" \
        -c "bullseye" \
        -s "testing" \
        -p "pool" \
        -r 'gpg_signing_key_name@example.com' \
        -P "/path/to/gpg_passphrase" \
        -k "/path/to/secring.gpg" \
        repository

`-O` and `-L` are optional, but be aware that if they are changed then clients
may complain about the repository being updated.

`-c` (codename) and `-s` (suite) are mandatory. For non-official repositories it
seems sensible to keep both as the codename.

`-p` is the package directory, relative to the top-level root repository
directory. Packages _can_ be directly in the root directory, but the Debian
repository documentation recommends against it. If in doubt, just use 'pool'.

`-r` is the signing key name. If unset then the repository won't be signed.

`-P` and `-k` are the GPG passphrase file and secret keyring file respectively.
Both are optional. If the passphrase is unset then it's assumed that `gpg-agent`
is running (or no passphrase is needed). If `-k` is set then a temporary
directory will be created, the keyring imported, and then it will be wiped
afterwards. Yes, gnupg is crazy in that you can't sign without needeing to
create a key directory first.

Finally, the directory of the repostitory must be given.


Updating the available packages
-------------------------------

It's easy to change the packages that are available. Add some new packages:

    mkdir respository/pool/release3
    cp /location3/*.deb respository/pool/release3/

Remove some old packages:

    rm -rf repository/pool/release1

Remove the `dists` directory from the repository (not strictly necessary as the
script will generally just overwrite the same files anyway):

    rm -rf repository/dists

and re-run the `apt-buildrepo` command above.


Future potential improvements
-----------------------------

Some things are definitely in scope for improvement, as long as they don't
distract from the "keep it simple" decision. None of these should be hard, but
just aren't currently needed for our own use.

- Config file: just to save needing to pass a lot of arguments when running.

- Add caching: a simple ".cache" file that keeps a record of all package
  checksums and contents to save recalculating every time the script is run.

- Enforce more checks on the packages, for example to ensure that no duplicates
  are included.

- Write to a temporary `dists` directory and when complete remove the old one
  and move the new one in place.

- Calculate checksums internally rather than calling out to `sha1sum` etc.

- Read Debian package information using a perl module or similar, rather than
  calling out to `dpkg-deb`.


Licence
-------

Copyright (c) 2024 Network RADIUS.

This program is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.


Credits
-------

The `apt-buildrepo` script was written by Matthew Newton
