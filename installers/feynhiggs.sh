#!/bin/sh

# The scripts receive as input the name and version of the package
NAME=$1
VERSION=$2

echo "Installing $NAME version $VERSION"

BASE_URL=http://wwwth.mpp.mpg.de/members/heinemey/feynhiggs/newversion
PACKAGE=$NAME-$VERSION
TAR_FILE=$NAME-$VERSION.tar.gz

rm -rf /usr/local/$PACKAGE
curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C /usr/local
if [ $? -ne 0 ] ; then
    echo "Unable to download package and uncompress package"
    exit 1
fi

rm -f /usr/local/$NAME
ln -s /usr/local/$PACKAGE /usr/local/$NAME




echo "Configure and make log at $PWD/make.log"
(./configure --prefix=/usr/local/$PACKAGE && make && make install) 2>&1 > make.log
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
