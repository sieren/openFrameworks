#!/bin/bash
set -ev
ROOT=$(cd $(dirname $0); pwd -P)
OF_ROOT=$(cd $ROOT/../../..; pwd -P)
PROJECTS=$OF_ROOT/libs/openFrameworksCompiled/project
export GCC_PREFIX=armv7l-unknown-linux-gnueabihf
export TOOLCHAIN_PREFIX=arm-linux-gnueabihf
export GST_VERSION=1.0
export RPI_ROOT=${OF_ROOT}/scripts/ci/linuxarmv7/archlinux
#export TOOLCHAIN_ROOT=/usr
export TOOLCHAIN_ROOT=$HOME/rpi2_toolchain
#${OF_ROOT}/scripts/ci/linuxarmv7/x-tools7h/${GCC_PREFIX}
export PLATFORM_OS=Linux
export PLATFORM_ARCH=armv7l
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=${RPI_ROOT}/usr/lib/pkgconfig:${RPI_ROOT}/usr/share/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${RPI_ROOT}
export CXX=${TOOLCHAIN_ROOT}/bin/${GCC_PREFIX}-g++
export CC=${TOOLCHAIN_ROOT}/bin/${GCC_PREFIX}-gcc
export AR=${TOOLCHAIN_ROOT}/bin/${GCC_PREFIX}-ar
export LD=${TOOLCHAIN_ROOT}/bin/${GCC_PREFIX}-ld
export CFLAGS="$CFLAGS --sysroot=${RPI_ROOT}"
export CXXFLAGS="$CXXFLAGS --sysroot=${RPI_ROOT}"

#cd $ROOT
#wget http://www.music.mcgill.ca/~gary/rtaudio/release/rtaudio-4.1.1.tar.gz
#tar xzf rtaudio-4.1.1.tar.gz
#cd rtaudio-4.1.1
#./configure --host=${GCC_PREFIX}
#sed -i "s|CFLAGS[ ]*=\(.*\)|CFLAGS = ${CFLAGS} \1|g" Makefile 
#perl -p -i -e 's|\$\(CC\) (?!\$\(CFLAGS\))|\$(CC) \$(CFLAGS) |g' Makefile

#make
#cp RtAudio.h ${RPI_ROOT}/usr/local/include/
#cp *.a ${RPI_ROOT}/usr/local/lib/
#cd $ROOT
#rm rtaudio-4.1.1.tar.gz
#rm -r rtaudio-4.1.1
cd $ROOT/archlinux
wget http://ci.openframeworks.cc/rtaudio-armv7hf.tar.bz2
tar xjf rtaudio-armv7hf.tar.bz2
rm rtaudio-armv7hf.tar.bz2
cd $ROOT

# Add compiler flag to reduce memory usage to enable builds to complete
# see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=56746#c7
# the "proper" way does not work currently:
export CXXFLAGS="$\(CXXFLAGS\) --param ftrack-macro-expansion=0"
CUSTOMFLAGS="-ftrack-macro-expansion=0"

echo "**** Building OF core ****"
cd $OF_ROOT
# this carries over to subsequent compilations of examples
echo "PLATFORM_CFLAGS += $CUSTOMFLAGS" >> $PROJECTS/linuxarmv7l/config.linuxarmv7l.raspberry2.mk
sed -i "s/PLATFORM_OPTIMIZATION_CFLAGS_DEBUG = .*/PLATFORM_OPTIMIZATION_CFLAGS_DEBUG = -g0/" $PROJECTS/makefileCommon/config.linux.common.mk
cd $PROJECTS


make Debug PLATFORM_VARIANT=raspberry2

echo "**** Building emptyExample ****"
cd $OF_ROOT/scripts/templates/linuxarmv7l
make Debug PLATFORM_VARIANT=raspberry2

echo "**** Building allAddonsExample ****"
#cd $OF_ROOT
#cp scripts/templates/linuxarmv7l/Makefile examples/addons/allAddonsExample/
#cp scripts/templates/linuxarmv7l/config.make examples/addons/allAddonsExample/
#cd examples/addons/allAddonsExample/
#make Debug PLATFORM_VARIANT=raspberry2

git checkout $PROJECTS/makefileCommon/config.linux.common.mk
git checkout $PROJECTS/linuxarmv7l/config.linuxarmv7l.default.mk
