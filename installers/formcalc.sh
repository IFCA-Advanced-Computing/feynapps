#!/bin/sh

# The scripts receive as input the name and version of the package
NAME=$1
VERSION=$2

echo "Installing $NAME version $VERSION"

export PATH=/usr/local/bin:$PATH

PREFIX=/usr/local
BASE_URL=http://www.feynarts.de/formcalc
PACKAGE=$NAME-$VERSION
TAR_FILE=$NAME-$VERSION.tar.gz

mkdir -p $PREFIX/src

logfile=$PREFIX/src/$NAME-$VERSION-make.log
echo "Configure and make log at $logfile"

make -f - << EOF > $logfile 2>&1
install:
	@echo "cleaning up"
	rm -rf $PREFIX/src/$PACKAGE
	rm -rf $PREFIX/$PACKAGE
	@echo "downloading package from $BASE_URL"
	curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C $PREFIX
	@echo "compiling"
	cd $PREFIX/$PACKAGE && \\
	./compile
	@echo "done."
EOF
if [ $? -ne 0 ] ; then
    echo "Installation error, check $logfile"
    exit 1
fi

if [ -L $PREFIX/$NAME ] ; then
    echo "Not changing the current link to $NAME in $PREFIX!"
else
    ln -s $PREFIX/$PACKAGE $PREFIX/$NAME
fi

. `dirname $0`/mathpath.sh
add_math_path $NAME $PREFIX/$NAME

echo "* $NAME v $VERSION installed at $PREFIX/$PACKAGE" >> /etc/motd

exit 0
