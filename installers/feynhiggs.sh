#!/bin/sh

# The scripts receive as input the name and version of the package
NAME=$1
VERSION=$2

echo "Installing $NAME version $VERSION"

export PATH=/usr/local/bin:$PATH

PREFIX=/usr/local
BASE_URL=http://wwwth.mpp.mpg.de/members/heinemey/feynhiggs/newversion
PACKAGE=$NAME-$VERSION
TAR_FILE=$NAME-$VERSION.tar.gz

mkdir -p $PREFIX/src

logfile=$PREFIX/src/$NAME-$VERSION-make.log
echo "Configure and make log at $logfile"

make -f - << EOF > $logfile 2>&1
InstallFeynHiggs:
	@echo "cleaning up"
	rm -rf $PREFIX/src/$PACKAGE
	rm -rf $PREFIX/$PACKAGE
	@echo "donwloading package from $BASE_URL"
	curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C $PREFIX/src
	@echo "compiling"
	cd $PREFIX/src/$PACKAGE && \\
	./configure --prefix=$PREFIX/$PACKAGE && \\
	make && \\
	make install
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


echo "export PATH=$PREFIX/$NAME/bin:\$PATH" > /etc/profile.d/z$NAME.sh
echo "export LD_LIBRARY_PATH=$PREFIX/$NAME/lib64:\$LD_LIBRARY_PATH" >> /etc/profile.d/z$NAME.sh
echo "setenv PATH $PREFIX/$NAME/bin:\${PATH}" > /etc/profile.d/z$NAME.csh
echo "setenv LD_LIBRARY_PATH $PREFIX/$NAME/lib64:\${LD_LIBRARY_PATH}" >> /etc/profile.d/z$NAME.csh

echo "* $NAME v $VERSION installed at $PREFIX/$PACKAGE" >> /etc/motd

exit 0
