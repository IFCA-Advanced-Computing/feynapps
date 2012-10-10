#!/bin/sh

# The scripts receive as input the name and version of the package
NAME=$1
VERSION=$2

echo "Installing $NAME version $VERSION"

PREFIX=/usr/local
BASE_URL=http://www.feynarts.de
PACKAGE=$NAME-$VERSION
TAR_FILE=$NAME-$VERSION.tar.gz

rm -rf $PREFIX/$PACKAGE
curl "$BASE_URL/$TAR_FILE" | tar -xzf - -C $PREFIX
if [ $? -ne 0 ] ; then
    echo "Unable to download package and uncompress package"
    exit 1
fi

rm -f $PREFIX/$NAME
ln -s $PREFIX/$PACKAGE $PREFIX/$NAME

cd $PREFIX/$PACKAGE

echo "Configure and make log at $PWD/make.log"
./compile 2>&1 > make.log
if [ $? -ne 0 ] ; then
    echo "Unable to compile package"
    exit 1
fi

mathcmd=`which math`

set -x
if "$mathcmd" -run "Print[4711]; Exit" < /dev/null | grep 4711 > /dev/null ; then
  eval -- `"$mathcmd" -run '
    org[$Failed] = "";
    org[file_] := File /. FileInformation[file];
    Print["fa=\"" <> org[System\`Private\`FindFile["FeynArts\`"]] <> "\""];
    Print["fc=\"" <> org[System\`Private\`FindFile["FormCalc\`"]] <> "\""];
    Print["lt=\"" <> org[System\`Private\`FindFile["LoopTools"]] <> "\""];
    Exit[]
  ' < /dev/null | tail -2 | tr '\r' ' '`
  
  mmapath="\"/$PREFIX/$PACKAGE\"""

  test -n "$mmapath" && "$mathcmd" -run "mmapath={0$mmapath}" -run '
    prefdir = ToFileName[$PreferencesDirectory, "Kernel"];
    If[ FileType[prefdir] === None, CreateDirectory[prefdir] ];
    hh = OpenAppend[ToFileName[prefdir, "init.m"]];
    Block[ {home = ToFileName[$HomeDirectory], $HomeDirectory, ToFileName},
      striphome[dir_] := If[ # == dir, #, ToFileName[$HomeDirectory, #] ]& @
        StringReplace[dir, home -> ""];
      SetAttributes[Write, HoldRest];
      With[ {path = striphome/@ Rest[mmapath]},
        Write[hh, $Path = Join[path, $Path]] ]
    ];
    Print["Modified ", Close[hh]];
    Exit[]
  ' < /dev/null | tail -1
fi


echo "export PATH=/usr/local/$PACKAGE/bin:\$PATH" > /etc/profile.d/z$PACKAGE.sh
echo "export LD_LIBRARY_PATH=/usr/local/$PACKAGE/lib64:\$LD_LIBRARY_PATH" >> /etc/profile.d/z$PACKAGE.sh
echo "setenv PATH /usr/local/$PACKAGE/bin:\${PATH}" > /etc/profile.d/z$PACKAGE.csh
echo "setenv LD_LIBRARY_PATH /usr/local/$PACKAGE/lib64:\${LD_LIBRARY_PATH}" >> /etc/profile.d/z$PACKAGE.csh

echo "* $NAME v $VERSION installed at /usr/local/$PACKAGE" >> /etc/motd

exit 0
