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

PACKAGE=$NAME-$VERSION

mkdir -p $SRC_DIR
PREFIX=`dirname $DEST_DIR`

logfile=$SRC_DIR/$NAME-$VERSION-make.log
echo "Configure and make log at $logfile"

if [ $NAME = "LoopTools" ]; then
    make -f - << EOF > $logfile 2>&1
install:
	@echo "cleaning up"
	rm -rf $SRC_DIR/$PACKAGE
	rm -rf $DEST_DIR
	@echo "Unpacking package at $TAR_FILE"
	tar -xzf $TAR_FILE -C $PREFIX
	@echo "compiling"
	cd $DEST_DIR && ./configure && \$(MAKE) default install clean 
	@echo "done."
EOF
elif [ $NAME = "FormCalc" ] ; then
    make -f - << EOF > $logfile 2>&1
install:
	@echo "cleaning up"
	rm -rf $SRC_DIR/$PACKAGE
	rm -rf $DEST_DIR
	@echo "Unpacking package at $TAR_FILE"
	tar -xzf $TAR_FILE -C $PREFIX
	@echo "compiling"
	cd $DEST_DIR && \\
	./compile
	@echo "done."
EOF

elif [ $NAME = "FeynArts" ] ; then
    make -f - << EOF > $logfile 2>&1
install:
	@echo "cleaning up"
	rm -rf $SRC_DIR/$PACKAGE
	rm -rf $DEST_DIR
	@echo "Unpacking package at $TAR_FILE"
	tar -xzf $TAR_FILE -C $PREFIX
	@echo "done."
EOF
fi

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
. `dirname $0`/mathpath.sh
add_math_path $NAME $PREFIX/$NAME || st=1
echo "* $NAME v $VERSION installed at $DEST_DIR" >> /etc/motd || st=1
exit $st 
