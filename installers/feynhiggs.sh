#!/bin/sh

# The scripts receive as input the name and version of the package
# and the locations to install and source
NAME=$1
VERSION=$2
DEST_DIR=$3
SRC_DIR=$4

echo "Installing $NAME version $VERSION"

export PATH=/usr/local/bin:$PATH

BASE_URL=http://wwwth.mpp.mpg.de/members/heinemey/feynhiggs/newversion
PACKAGE=$NAME-$VERSION
TAR_FILE=$NAME-$VERSION.tar.gz

mkdir -p $SRC_DIR

logfile=$SRC_DIR/$NAME-$VERSION-make.log
echo "Configure and make log at $logfile"

make -f - << EOF > $logfile 2>&1
InstallFeynHiggs:
	@echo "cleaning up"
	rm -rf $SRC_DIR/$PACKAGE
	rm -rf $DEST_DIR
	@echo "donwloading package from $BASE_URL"
	curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C $SRC_DIR
	@echo "compiling"
	cd $SRC_DIR/$PACKAGE && \\
	./configure --prefix=$DEST_DIR && \\
	make && \\
	make install
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


echo "export PATH=$PREFIX/$NAME/bin:\$PATH" > /etc/profile.d/z$NAME.sh
echo "export LD_LIBRARY_PATH=$PREFIX/$NAME/lib64:\$LD_LIBRARY_PATH" >> /etc/profile.d/z$NAME.sh
echo "setenv PATH $PREFIX/$NAME/bin:\${PATH}" > /etc/profile.d/z$NAME.csh
echo "setenv LD_LIBRARY_PATH $PREFIX/$NAME/lib64:\${LD_LIBRARY_PATH}" >> /etc/profile.d/z$NAME.csh

echo "* $NAME v $VERSION installed at $DEST_DIR" >> /etc/motd

exit 0
