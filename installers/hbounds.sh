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

PREFIX=`dirname $DEST_DIR`

make -f - << EOF > $logfile 2>&1
InstallHiggsBounds:
	@echo "cleaning up"
	rm -rf $SRC_DIR/$PACKAGE
	rm -rf $DEST_DIR
	@echo "Unpacking package at $TAR_FILE"
	tar -xzf $TAR_FILE -C $SRC_DIR
	mv $SRC_DIR/HiggsBounds-$VERSION/HiggsBounds $DEST_DIR
	@echo "fixing feynhiggs location"
	sed -i -e "/^FHINCLUDE =/s#.*#FHINCLUDE = -I$PREFIX/FeynHiggs/include#" $DEST_DIR/configure
	sed -i -e "/^FHLIBS =/s#.*#FHLIBS = -L$PREFIX/FeynHiggs/lib -lFH#" $DEST_DIR/configure	
	@echo "compiling"
	cd $DEST_DIR && \\
	./configure && make
	@echo "done."
EOF
if [ $? -ne 0 ] ; then
	echo "Installation error, check $logfile"
	exit 1
fi

if [ -L $PREFIX/$NAME ] ; then
	echo "Not changing the current link to $NAME in $PREFIX!"
else
	ln -s $DEST_DIR $PREFIX/$NAME
fi

st=0
echo "* $NAME v $VERSION installed at $DEST_DIR" >> /etc/motd || st=1
exit $st
