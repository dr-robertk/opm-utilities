#!/bin/bash

# replace this link with your OPM fork
OPMURL=https://github.com/OPM/

# this script downloads the necessary set of dune opm modules
# to run the opm-simulators, in particular the blackoil simulator flow

#change appropriately, i.e. 2.4, 2.5 or empty which refers to master

# when empty the current master is selected
#OPMVERSION=2017.04
DUNEVERSION=2.4

# add necessary flags if needed
FLAGS="-O3 -DNDEBUG -Wall -ftree-vectorize -mtune=native"

# needed DUNE core modules
DUNEMODULES="dune-common dune-geometry dune-grid dune-istl"

# needed OPM modules
OPMMODULES="opm-common opm-output opm-parser opm-material opm-grid opm-core ewoms opm-simulators"

OPMBRANCH=
if [ "$OPMVERSION" != "" ] ; then
  OPMBRANCH="-b release/$OPMVERSION"
fi

# libecl is a necessary prerequisite for opm-parser
LIBECL=libecl
############################################################################
# Installation of libecl
git clone $OPMBRANCH https://github.com/Statoil/$LIBECL.git
if ! test -d $LIBECL ; then
  echo "Problem with $LIBECL directory"
  exit 1
fi
cd $LIBECL
LIBECL_INSTALLDIR=`pwd`/install-$LIBECL
if ! test -d build ; then
  mkdir build ; cd build
  # sometimes it might be necessary to also specify the path to ping command
  PINGPATH=/bin
  cmake ../ -DCMAKE_INSTALL_PREFIX=$LIBECL_INSTALLDIR
  make -j4 ; make install
  cd ../
fi
cd ../
############################################################################

# build flags for all DUNE and OPM modules
# change according to your needs
if ! test -f config.opts ; then
echo "\
OPMDIR=`pwd`
BUILDDIR=build
USE_CMAKE=yes
MAKE_FLAGS=-j4
CMAKE_FLAGS=\"-DCMAKE_CXX_FLAGS=\\\"$FLAGS\\\"  \\
 -DOPM_COMMON_ROOT=\$OPMDIR/opm-common \\
 -Decl_DIR=\$OPMDIR/$LIBECL/build \\
 -DSILENCE_EXTERNAL_WARNINGS=ON \\
 -DSIBLING_SEARCH=OFF \\
 -DBUILD_TESTING=OFF\" " > config.opts
fi

DUNEBRANCH=
if [ "$DUNEVERSION" != "" ] ; then
  DUNEBRANCH="-b releases/$DUNEVERSION"
fi

# get all dune modules necessary
for MOD in $DUNEMODULES ; do
  git clone $DUNEBRANCH http://gitlab.dune-project.org/core/$MOD
done

# get all OPM modules necessary
for MOD in $OPMMODULES ; do
  URL="$OPMURL$MOD"
  if [ "$MOD" == "opm-data" ] ; then
    git clone $URL
  else
    git clone $OPMBRANCH $URL
  fi
done

# build all DUNE and OPM modules in the correct order
./dune-common/bin/dunecontrol --opts=config.opts all
