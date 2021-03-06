#!/bin/bash
# Bootstrap Pharo 1.4 Linux VM and image from upstream
set -e

# Some useful vars for later
SCRIPTDIR="`dirname $0`"
PKGNAME="`basename $0 .sh`"
TSTNAME="${PKGNAME}-Tests"
IMGNAME=Pharo-1.4.image

# Output and test results we will generate
PKGFILE="${PKGNAME}.zip"
TSTFILE="${TSTNAME}.zip"

# Upstream Jenkins
UPSTREAM=https://ci.lille.inria.fr/pharo/job

# VM, image and sources we need to bootstrap
VMPROJ="Cog-VM/Architecture=32,OS=linux"
VM_ART=Cog-linux.zip
PHPROJ="Pharo%201.4"
PH_ART=Pharo-1.4.zip
SRCURL=https://gforge.inria.fr/frs/download.php/24391/PharoV10.sources.zip
SRCFILE=PharoV10.sources.zip

# Get the last successful build number from upstream Jenkins
# First argument is job name
function get_buildnum {
    # Delete everything but numbers using tr to avoid malicious input
    curl -fsS "$UPSTREAM/$1/lastSuccessfulBuild/buildNumber" | tr -dc 0123456789
}

# Retrieve an upstream artifact into a local file
# First argument is local output file
# Second is Jenkins job name
# Third is build number
# Fourth is Jenkins artifact name
function get_buildfile {
    if [ ! -e "$1" ]; then
        echo "Fetching $2/$3/$4 -> $1"
	rm -f "$1.tmp"
        curl -fsS -o "$1.tmp" "$UPSTREAM/$2/$3/artifact/$4"
        mv -f "$1.tmp" "$1"
    else
	echo "$1 is up to date"
    fi
}

# Retrieve VM into local zip file from Jenkins
# Local file includes build number for tracking
if [ -z "$VMPEG" ]; then
    echo "Checking current $VMPROJ build number"
    VBLD=`get_buildnum "$VMPROJ"`
else
    echo "Using $VMPROJ peg build $VMPEG"
    VBLD="$VMPEG"
fi
VMFILE=cog-linux-${VBLD}.zip
get_buildfile "$VMFILE" "$VMPROJ" ${VBLD} "$VM_ART"

# Retrieve Pharo 1.4 image into local zip file from Jenkins
# Local file includes build number and update number for tracking
# We can use the update number here as a regular convention is used
if [ -z "$PHPEG" ]; then
    echo "Checking current $PHPROJ build number"
    PBLD=`get_buildnum "$PHPROJ"`
    PURL="$UPSTREAM/$PHPROJ/$PBLD/api/xml?xpath=/*/description"
    PREV=`curl -fsS "${PURL}" | cut -f2 -d " " | tr -dc 0123456789`
else
    echo "Using $PHPROJ peg build $PHPEG"
    PBLD="$PHPEG"
    PREV="`echo Pharo-1.4-${PBLD}-*.zip | sed -e 's/Pharo-1.4-\([0-9]\+\)-\([0-9]\+\).zip/\2/'`"
fi
echo "Build number $PBLD revision $PREV"
PHFILE="Pharo-1.4-${PBLD}-${PREV}.zip"
get_buildfile "$PHFILE" "$PHPROJ" ${PBLD} "$PH_ART"

# Using a new build directory, unpack the upstream bits.
# We then annotate the output with the versions of the VM
# and image that are included.
rm -rf build && mkdir build && unzip -qjo -d build "$PHFILE" && unzip -qjo -d build "$VMFILE"
echo "Cog VM build $VBLD from $UPSTREAM/$VMPROJ" >> build/VERSIONS
echo "Pharo 1.4 image build $PBLD rev $PREV from $UPSTREAM/$PHPROJ" >> build/VERSIONS
"$SCRIPTDIR/runscripts.sh" "$PKGNAME" "$IMGNAME" \
    st/pharo-base.st
rm -f "$PKGFILE" && zip -qj "$PKGFILE" build/*
echo "$PKGFILE created"

# Run the tests and zip these up into an artifact as well.
rm -f "$TSTFILE" && zip -qj "$TSTFILE" build/*
"$SCRIPTDIR/runscripts.sh" "$TSTNAME" "$IMGNAME" \
    st/pharo-runtests.st
zip -qj "$TSTFILE" build/*.log build/*.xml
echo "$TSTFILE created"

## END ##
