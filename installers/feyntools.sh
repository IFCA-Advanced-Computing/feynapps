#!/bin/sh

# The scripts receive as input the name and version of the package
# and the locations to install and source
NAME=$1
VERSION=$2
DEST_DIR=$3
SRC_DIR=$4

echo "Installing $NAME version $VERSION"

export PATH=/usr/local/bin:$PATH

BASE_URL=http://www.feynarts.de
if [ $NAME = "LoopTools" ] ; then
    BASE_URL=$BASE_URL/looptools
elif [ $NAME = "FormCalc" ] ; then
    BASE_URL=$BASE_URL/formcalc
fi
PACKAGE=$NAME-$VERSION
TAR_FILE=$NAME-$VERSION.tar.gz

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
	@echo "downloading package from $BASE_URL"
	curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C $PREFIX
	@echo "compiling"
	cd $DESTDIR && ./configure && \$(MAKE) default install clean 
	@echo "done."
EOF
elif [ $NAME = "FormCalc" ] ; then
    make -f - << EOF > $logfile 2>&1
install:
	@echo "cleaning up"
	rm -rf $SRC_DIR/$PACKAGE
	rm -rf $DEST_DIR
	@echo "downloading package from $BASE_URL"
	curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C $PREFIX
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
	@echo "downloading package from $BASE_URL"
	curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C $PREFIX
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

. `dirname $0`/mathpath.sh
add_math_path $NAME $PREFIX/$NAME

echo "* $NAME v $VERSION installed at $DEST_DIR" >> /etc/motd

exit 0
