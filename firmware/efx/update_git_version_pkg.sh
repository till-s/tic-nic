#!/usr/bin/env bash

here=`dirname $0`
echo "running from $here"

f="$here/../hdl/GitVersionPkg.vhd"
ver="00000000"

if git diff-index --quiet HEAD -- ; then
  ver=`git rev-parse --short=8 HEAD`
else
  echo "HEAD seems to be dirty; using version 00000000"
fi
echo "-- AUTOMATICALLY GENERATED; DO NOT EDIT"                                 >  $f
echo "library ieee;"                                                           >> $f
echo "use ieee.std_logic_1164.all;"                                            >> $f
echo ""                                                                        >> $f
echo "package GitVersionPkg is"                                                >> $f
echo "   constant GIT_VERSION_C : std_logic_vector(31 downto 0) := x\"$ver\";" >> $f
echo "end package GitVersionPkg;"                                              >> $f
