#!/bin/sh

# The scripts receive as input the name and version of the package
NAME=$1
VERSION=$2

echo "Installing $NAME version $VERSION"

BASE_URL=http://wwwth.mpp.mpg.de/members/heinemey/feynhiggs/newversion
PACKAGE=$NAME-$VERSION
TAR_FILE=$NAME-$VERSION.tar.gz

curl "$BASE_URL/$TAR_FILE" | tar -xzf -
if [ $? -ne 0 ] ; then
    echo "Unable to download package"
    exit 1
fi

cd $PACKAGE

./configure --prefix=/usr/local/$PACKAGE && make && make install
if [ $? -ne 0 ] ; then
    echo "Unable to compile package"
    exit 1
fi

echo "export PATH=/usr/local/$PACKAGE/bin:\$PATH" > /etc/profile.d/z$PACKAGE.sh
echo "export LD_LIBRARY_PATH=/usr/local/$PACKAGE/lib64:\$LD_LIBRARY_PATH" >> /etc/profile.d/z$PACKAGE.sh
echo "setenv PATH /usr/local/$PACKAGE/bin:\${PATH}" > /etc/profile.d/z$PACKAGE.csh
echo "setenv LD_LIBRARY_PATH /usr/local/$PACKAGE/lib64:\${LD_LIBRARY_PATH}" >> /etc/profile.d/z$PACKAGE.csh

echo "* $NAME v $VERSION installed at /usr/local/$PACKAGE" >> /etc/motd

exit 0
