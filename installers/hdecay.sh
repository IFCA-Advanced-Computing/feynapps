#!/bin/sh

# The scripts receive as input the name and version of the package
# and the locations to install and source
NAME=$1
VERSION=$2
TAR_FILE=$3
DEST_DIR=$4
SRC_DIR=$5

echo "Installing $NAME version $VERSION"

export PATH=/usr/local/bin:$PATH

PACKAGE=$NAME

mkdir -p $SRC_DIR

logfile=$SRC_DIR/$NAME-$VERSION-make.log
echo "Configure and make log at $logfile"

make -f - << EOF > $logfile 2>&1
InstallHdecay:
	@echo "cleaning up"
	rm -rf $SRC_DIR/$PACKAGE
	rm -rf $DEST_DIR
	mkdir -p $DEST_DIR
	@echo "Unpacking package at $TAR_FILE"
	tar -xzf $TAR_FILE -C $DEST_DIR
	@echo "compiling"
	cd $DEST_DIR && \\
	make FC=gfortran
	@echo "done."
EOF
if [ $? -ne 0 ] ; then
	echo "Installation error, check $logfile"
	exit 1
fi

PREFIX=`dirname $DEST_DIR`

if [ -L $PREFIX/$NAME ] ; then
	echo "Not changing the current link to $NAME in $PREFIX!"
else
	ln -s $DEST_DIR $PREFIX/$NAME
fi

st=0
echo "* $NAME v $VERSION installed at $DEST_DIR" >> /etc/motd || st=1
exit $st
