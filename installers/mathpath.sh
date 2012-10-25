#!/bin/bash

#
# modifies mathemathica path to include packages
#
add_math_path () {
  NAME=$1
  LOCATION=$2

  if [ "x$NAME" != "xLoopTools" ] ; then
    PCK=${NAME}\`
  else
    PCK=$NAME
  fi

  mathcmd=`which math`

  if "$mathcmd" -run "Print[4711]; Exit" < /dev/null | grep 4711 > /dev/null ; then
      $mathcmd -run "mmapath={0, \"$LOCATION\"}" -run '
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
}
